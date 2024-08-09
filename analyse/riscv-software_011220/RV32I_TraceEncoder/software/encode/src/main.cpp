#include <fstream>
#include <iostream>
#include <vector>
#include <bitset>
#include "riscv-disas.h"
#include "te_definitions.h"
#include "encoder-algorithm-public.h"
#include "decoder-algorithm-public.h"
#include <cassert>
using namespace std;

// global variables
static te_address_t last_te_iaddress = 0;
static bool te_full_address_option = true;

// define if we trace the context change. In RISCV EC-SAS, the context can't change now so NOCONTEXT_P is 1
#define NOCONTEXT_P 1
#define FULL_ADDRESS_OPTION 1  // full address option
#define DIFF_ADDRESS_OPTION 0  // full address option

// constant defined in vhdl for RISCV EC-SAS
#define PACKET_MAX_LENGTH 104
#define IADDRESS_LSB 0          // first significative address bit
#define IADDRESS_WIDTH_P 32     // address bus width
#define INSTR_WIDTH_P 32        // instruction length
#define PRIVILEGE_WIDTH_P 2     // bits to indicate current privilege (00: User/application ; 01: Supervisor; 11: Machine)
#define MCAUSE_WIDTH_P 32       // supervision cause register size. The 31th bit is set as 0 if exception, 1 in case of interrupt

static void fill_record_instruction(uint64_t iaddress, uint64_t next_iaddress, uint64_t instruction, te_instruction_record_t *Arecord){
    // get opcode
    uint64_t opcode = (instruction & 0x7F);
    uint8_t Rd = (instruction >> 7) & 0x1F; 
    uint8_t Rs = (instruction >> 15) & 0x1F;

    Arecord->pc = iaddress;     /* program counter of retired instruction */
    Arecord->tval = 0;           /* same as instruction address width */
    Arecord->priv = 0;          /* up to 4-bits -> set as user privilege 00 */
    Arecord->context = 0;       /* up to 32-bits */

    /* set of boolean flags */
    Arecord->is_exception = false;
    if (Arecord->is_exception){
        // TODO : set exception cause
    } else {
        Arecord->exception_cause = 0;
    }
    
    Arecord->is_interrupt = false;
    Arecord->is_branch = (opcode == 0x63);
    Arecord->is_updiscon = (opcode == 0x67);
    /* is branch taken ? */ 
    if (next_iaddress != -1) {
        Arecord->cond_code_fail = (next_iaddress - iaddress) == 4; // 4 bytes for rv32
    } else {
        Arecord->cond_code_fail = true;
    }
    /* was it a (non-tail) function call ? */
    Arecord->is_call = (opcode == 0x6F && (Rd == 0x1 || Rd == 0x5)) || (opcode == 0x67 && (Rd == 0x1 && Rs != 0x5));
    /* return as JALR X0, X1 ? */
    if ((opcode == 0x67) && (Rd == 0x0) && (Rs == 0x1)) {
//    if ((opcode == 0x67) && ((Rd != 0x1) && (Rd != 0x5)) && ((Rs == 0x1) || (Rs == 0x5))) {
        Arecord->is_return = true;
    } else {
        Arecord->is_return = false;
    }
    /* is the current instruction qualified ? */
    if ((opcode == 0x73) || (opcode == 0x63) || (opcode == 0x6F) || (opcode == 0x67)) {
        Arecord->is_qualified = true;  
    } else {
        Arecord->is_qualified = false;
    }
    /* true if the CPU in debug mode -> no debug now in RISCV EC-SAS */
    Arecord->is_halted = false; 
}

void fill_bitset(uint64_t data, uint8_t width, uint32_t *start, bitset<PACKET_MAX_LENGTH> *te_bits){
    uint32_t idx = *start;
    for(int i = 0; i < width; i++){
        data & (1 << i) ? te_bits->set(idx++) : te_bits->reset(idx++);  ;
    }
    *start = idx;
}

void te_send_te_inst(void * const user_data, const te_inst_t * const te_inst){
    assert(te_inst);
    assert(user_data);

    vector<tInstr> *program = (vector<tInstr> *) user_data;
    uint32_t addressIdx;
    uint32_t instr;
    uint32_t address;
    uint32_t imm = 0;
    char buf[128]= { 0 };
    if (te_inst->with_address){
        if (te_full_address_option) {
            addressIdx = (te_inst->address) >> (2 - IADDRESS_LSB);
        } else {
            last_te_iaddress = last_te_iaddress + te_inst->address;
            addressIdx = (last_te_iaddress) >> (2 - IADDRESS_LSB);   
        }
        address = program->at(addressIdx).address;
        instr = program->at(addressIdx).instruction_code;
        disasm_inst(buf, sizeof(buf), rv32, address, instr);
        imm = (instr & 0x80000000) ? 0xFFFFF000 : 0x0;
        imm += (instr & 0x00000080) << 4;
        imm += (instr & 0x7E000000) >> 20;
        imm += (instr & 0x00000F00) >> 7;
    }
    // compute bit vector value to compare to RISCV EC-SAS trace encoder output
    bitset<PACKET_MAX_LENGTH> te_bits;
    uint32_t te_packet_length = 0;
    uint8_t te_options = 0;
    
    cout << "te_inst[ format=";
    switch(te_inst->format){
        case TE_INST_FORMAT_0_EXTN:
            cout << "0 (EXTN): "; /* (optional efficiency extensions) */
           // TO CONTINUE
            fill_bitset(TE_INST_FORMAT_0_EXTN, 2, &te_packet_length, &te_bits);
            break;
        case TE_INST_FORMAT_1_DIFF:
            cout << "1 (DIFF_DELTA): "; /* 01 (diff-delta) */
            cout << "branches=" << te_inst->branches;
            cout << ", branch_map=" << hex << te_inst->branch_map;
            cout << ", address=0x" << hex << te_inst->address << ", (delta=0x" << hex << imm << ")";
            cout << ", updiscon = " << (te_inst->updiscon ? 1:0);
            // add te_bits
            fill_bitset(TE_INST_FORMAT_1_DIFF, 2, &te_packet_length, &te_bits);
            fill_bitset(te_inst->branches, 5, &te_packet_length, &te_bits);
            fill_bitset(te_inst->branch_map, te_inst->branches, &te_packet_length, &te_bits);
            fill_bitset(te_inst->address, IADDRESS_WIDTH_P - IADDRESS_LSB, &te_packet_length, &te_bits);
            fill_bitset(te_inst->notify, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->updiscon, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->irfail, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->irdepth, 9, &te_packet_length, &te_bits); 
            break;
        case TE_INST_FORMAT_2_ADDR:
            cout << "2 (ADDR_ONLY): address=0x"; /* 10 (addr-only) */
            // address
            cout << hex << te_inst->address;
            // notify
            if ((te_inst->address & 0x80000000) != te_inst->notify){
                cout << ", notify = " << (te_inst->notify ? 1:0);
            }
            // updiscon
            cout << ", updiscon = " << (te_inst->updiscon ? 1:0);
            // TBD : irreport and irdepth can be displayed in case of implicit return option is set
            // add te_bits
            fill_bitset(TE_INST_FORMAT_2_ADDR, 2, &te_packet_length, &te_bits);
            fill_bitset(te_inst->address, IADDRESS_WIDTH_P - IADDRESS_LSB, &te_packet_length, &te_bits);
            fill_bitset(te_inst->notify, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->updiscon, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->irfail, 1, &te_packet_length, &te_bits);
            fill_bitset(te_inst->irdepth, 9, &te_packet_length, &te_bits);
            break;
        case TE_INST_FORMAT_3_SYNC:
            cout << "3 (SYNC):"; /* 11 (sync) */
            fill_bitset(TE_INST_FORMAT_3_SYNC,2,&te_packet_length,&te_bits);
            switch(te_inst->subformat){
                case TE_INST_SUBFORMAT_START: // 00 (start)
                    cout << "priv: " << te_inst->privilege;
                    #ifndef NOCONTEXT_P
                        cout << " context: " << hex << te_inst->context;
                    #endif
                    cout << " address=0x" << hex << te_inst->address << " (opcode: 0x" << buf << ")";
                    if (!te_inst->branch){ // address points to a branch instruction and branch was taken
                        cout << " TAKEN";
                    }
                    // add te_bits
                    fill_bitset(TE_INST_SUBFORMAT_START, 2, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->branch, 1, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->privilege, PRIVILEGE_WIDTH_P, &te_packet_length, &te_bits);
                    #ifndef NOCONTEXT_P
                        fill_bitset(te_inst->context, CONTEXT_WIDTH_P, &te_packet_length, &te_bits);
                    #endif
                    fill_bitset(te_inst->address, IADDRESS_WIDTH_P - IADDRESS_LSB, &te_packet_length, &te_bits);
                    break;
                case TE_INST_SUBFORMAT_EXCEPTION: // 01 (exception)
                    cout << "priv: " << te_inst->privilege;
                    #ifndef NOCONTEXT_P
                        cout << " context: " << hex << te_inst->context;
                    #endif
                    if (te_inst->interrupt && te_inst->ecause == TE_ECAUSE_ILLEGAL_INSTRUCTION) {
                        cout << " illegal instruction at address 0x" << hex << te_inst->tvalepc;
                        cout << " jump to exception address 0x" << hex << te_inst->address;
                    } else {
                        cout << "exception cause:" << hex << te_inst->ecause;
                        cout << " at address 0x" << hex << te_inst->tvalepc;
                        cout << " trap value : 0x" << hex << te_inst->address;
                    }
                    // add ecause, interrupt, address, trap value bits (00: User mode)
                    fill_bitset(TE_INST_SUBFORMAT_EXCEPTION, 2, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->branch, 1, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->privilege, PRIVILEGE_WIDTH_P, &te_packet_length, &te_bits);
                    #ifndef NOCONTEXT_P
                        fill_bitset(te_inst->context, CONTEXT_WIDTH_P, &te_packet_length, &te_bits);
                    #endif
                    fill_bitset(te_inst->ecause, MCAUSE_WIDTH_P, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->interrupt, 1, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->address, IADDRESS_WIDTH_P - IADDRESS_LSB, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->tvalepc, IADDRESS_WIDTH_P, &te_packet_length, &te_bits);
                    break;
#ifndef NOCONTEXT_P
                case TE_INST_SUBFORMAT_CONTEXT: // 10 (context)
                    cout << "priv: " << hex << te_inst->privilege;
                    cout << "context: " << hex << te_inst->context;
                    // add te_bits
                    fill_bitset(TE_INST_SUBFORMAT_CONTEXT, 2, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->privilege, PRIVILEGE_WIDTH_P, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->context, CONTEXT_WIDTH_P, &te_packet_length, &te_bits);
                    break;
#endif
                case TE_INST_SUBFORMAT_SUPPORT: // 11 (support)
                    // TODO : display enable, mode
                    cout << "qualification status = " << te_inst->support.qual_status;
                    switch(te_inst->support.qual_status){
                        case TE_QUAL_STATUS_NO_CHANGE:   /* 00 (no_change) */
                            cout << " (NO CHANGE)";
                            break;
                        case TE_QUAL_STATUS_ENDED_REP:   /* 01 (ended_reported) */
                            cout << " (ENDED REPORTED)";
                            break;
                        case TE_QUAL_STATUS_TRACE_LOST:  /* 10 (trace_lost) */
                            cout << " (TRACE LOST)";
                            break;
                        case TE_QUAL_STATUS_ENDED_UPD:    /* 11 (ended_updiscon) */
                            cout << " (ENDED UPDISCON";
                            break;
                        default:
                            assert(0); // illegal qualification status
                    }
                    // display options <-> te_inst->support.options;
                    te_options = te_inst->support.options.implicit_return ? TE_OPTIONS_IMPLICIT_RETURN : 0;
                    te_options += te_inst->support.options.implicit_exception ? TE_OPTIONS_IMPLICIT_EXCEPTION : 0;
                    te_options += te_inst->support.options.full_address ? TE_OPTIONS_FULL_ADDRESS : 0;
                    te_options += te_inst->support.options.jump_target_cache ? TE_OPTIONS_JUMP_TARGET_CACHE : 0;
                    te_options += te_inst->support.options.branch_prediction ? TE_OPTIONS_BRANCH_PREDICTION : 0;
                    // add te_bits
                    fill_bitset(TE_INST_SUBFORMAT_SUPPORT, 2, &te_packet_length, &te_bits);
                    // TBD : enable (always enable ???)
                    fill_bitset(1, 1, &te_packet_length, &te_bits);
                    fill_bitset(te_inst->support.encoder_mode, TE_ENCODER_MODE_BITS, &te_packet_length, &te_bits);
                    fill_bitset(TE_QUAL_STATUS_NO_CHANGE, 2, &te_packet_length, &te_bits);
                    fill_bitset(te_options, TE_OPTIONS_NUM_BITS, &te_packet_length, &te_bits);
                    break;
                default:
                    assert(0); // illegal subformat
                    break;
            }
            break;
        default:
            break;
    } 
    cout << "]" << endl;
    cout << "te_inst binary trace [" << te_bits.to_string().substr(PACKET_MAX_LENGTH - te_packet_length, PACKET_MAX_LENGTH) << "] / te_inst hex trace [" << hex << te_bits.to_ullong() << "]" << endl;
}

bool te_prefer_jtc_extension(void * const user_data, te_inst_t * const te_inst){
    return false;
}


int main(int argc, char **argv)
{
    if (argc != 4) {
        // display help
        cerr << "Error  : bad arguments => " << argv[0] << " <hex program filename> <trace output filename> <differential mode = 1:0>" << endl;
        return -1;
    }

    // read programs
    fstream hexfile;
    hexfile.open(argv[1]); // default is 'in' mode
    if (!hexfile.is_open()) {
        // display : unable to read file
        cerr << "Error : unable to open file " << argv[1] << endl;
        return(-1);
    }
    
    // read instructions
    vector<tInstr> program;
    uint32_t PC = 0;
    uint32_t instruction;
    while(hexfile.good()){
        hexfile >> hex >> instruction;    
        tInstr AnInstruction;
        AnInstruction.address = (PC++) << 2;
        AnInstruction.instruction_code = instruction;
        program.push_back(AnInstruction);
    }

    // close file
    hexfile.close();

    fstream tracefile;
    tracefile.open(argv[2]); // default is 'in' mode
    if (!tracefile.is_open()) {
        // display : unable to read file
        cerr << "Error : unable to open file " << argv[2] << endl;
        return(-1);
    }
    
    // read instructions
    vector<tInstr> executed_instructions;
    while(tracefile.good()){
        tracefile.ignore(100,'x');
        tracefile >> hex >> PC;
        tracefile.ignore(100,'x');
        tracefile >> hex >> instruction;    
        tInstr AnInstruction;
        AnInstruction.address = PC;
        AnInstruction.instruction_code = instruction;
        executed_instructions.push_back(AnInstruction);
    }

    // close file
    tracefile.close();

    // create encoder
    te_encoder_state_t *encoder = te_open_trace_encoder(NULL, &program);
    FILE *debugFile = NULL;
    debugFile = fopen("te_encoder.dbg", "w");
    encoder->debug_stream = debugFile;
    // set debug options
    encoder->debug_flags = TE_DEBUG_PC_TRANSITIONS | TE_DEBUG_IMPLICIT_RETURN | TE_DEBUG_FOLLOW_PATH | TE_DEBUG_PACKETS | TE_DEBUG_JUMP_TARGET_CACHE | TE_DEBUG_BRANCH_PREDICTION;

    // NOTE: compressed instruction is not supported in RISCV EC-SAS
    encoder->discovery_response.iaddress_lsb = IADDRESS_LSB;
    encoder->set_trace.max_resync = 0; // no resynchronisation in RISCV EC-SAS

    // TBD: set options
    if (argv[3][0] == '1'){
        te_full_address_option = true;
        encoder->options.full_address = FULL_ADDRESS_OPTION;
    } else {
        te_full_address_option = false;
        encoder->options.full_address = DIFF_ADDRESS_OPTION;
    }
    encoder->options.implicit_return =  true;

    uint64_t iaddress, next_iaddress;
    uint64_t instr;
    char buf[128] = { 0 };
    for(uint32_t i = 0; i < executed_instructions.size(); i++){
        iaddress = executed_instructions[i].address;
        if (i < executed_instructions.size()-1){
            next_iaddress = executed_instructions[i+1].address;
        } else {
            next_iaddress = -1;
        }
        instr = executed_instructions[i].instruction_code;
        disasm_inst(buf, sizeof(buf), rv32, iaddress, instr);
        cout << "0x" << hex << iaddress <<  " , " << buf << endl;
        te_instruction_record_t Arecord;
        fill_record_instruction(iaddress, next_iaddress, instr, &Arecord);
        te_encode_one_irecord(encoder, &Arecord);    
    }

    if (debugFile){
        fclose(debugFile);
        encoder->debug_stream = NULL;
    }
    // delete decoder
    free(encoder);
    return(0);
}
