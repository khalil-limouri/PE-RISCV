#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include "te_definitions.h"
#include "riscv-disas.h"
#include <cassert>
#include <bitset>

using namespace std;

// define to get more informations during code execution
#define _DEBUG

uint32_t next_block(uint32_t idx, vector<tInstr> *program){
    assert(program);

    #ifdef _DEBUG
    char buf[128] = {0};
    #endif

    uint8_t opcode;
    uint32_t i = idx;
    uint32_t instruction;
    uint32_t iaddress;
    bool flow_discontinuity = false;
    do {
        instruction = program->at(i).instruction_code;
        iaddress = program->at(i).address;
        #ifdef _DEBUG
            disasm_inst(buf, sizeof(buf), rv32, iaddress, instruction);
            cout << "\t0x" << hex << iaddress << " " << buf << endl;      
        #endif
        opcode = (instruction & 0x7F);
        flow_discontinuity = (opcode == 0x73) || (opcode == 0x63) || (opcode == 0x6F) || (opcode == 0x67);
        if (!flow_discontinuity && (i < program->size())){
            i++;
        }
    }while(!flow_discontinuity);
    return(i);
}

int main(int argc, char **argv)
{
    if (argc != 4) {
        // display help
        cerr << "Error  : bad arguments => " << argv[0] << " <hex program filename> <output vhdl filename> <Program size>" << endl;
        return -1;
    }
    
    uint32_t length = strlen( argv[3] );
        char* buffer=argv[3];
        bool isCorrect = true;
        if ( !isdigit( *buffer ) ) {
            isCorrect = false;
        }
    
  
	if ( isCorrect==false ) {
		cerr << "Error  : bad arguments => " <<"\"" << atoi(argv[3]) << "\"" <<argv[0] << " Please enter a positive integer" << endl;
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
  //  uint32_t program_size= atoi(argv[3]);  //AZ//23/04/21 Normalement c'est le nombre des lignes du fichier .dis *4.
  //  program.resize(program_size);
  // cout << "\t" <<program_size  << endl;
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

    char buf[128] = {0};
    bool flow_discontinuity;
    uint8_t opcode ;
    uint32_t current_iaddress;
    uint32_t next_iaddress;
    uint32_t next_iaddress_idx;
    uint32_t discontinuity_iaddress;
    uint32_t discontinuity_iaddress_idx;
    uint32_t imm;
    uint32_t Rd;
    uint32_t block_not_taken;
    uint32_t block_not_taken_iaddress;
    uint32_t block_not_taken_instruction;
    uint32_t block_taken;
    uint32_t block_taken_iaddress;
    uint32_t block_taken_instruction;
    uint32_t check = 0;
    uint32_t iaddress_space = 0;
	//kl
    uint32_t Rs = 0; //  registre source pour l'instruction jalr
    uint32_t cpt_branch = 0; // compteur d'occurences de branchement
    uint32_t cpt_jal = 0; // compteur d'occurences de saut direct
    uint32_t cpt_jal_jump = 0; // compteur d'occurences de saut direct qui ne correspondent pas à un appel de fonction
    uint32_t cpt_jal_call = 0; // compteur d'occurences de saut direct qui correspondent à un appel de fonction
    uint32_t cpt_jalr = 0; // compteur d'occurences de saut indirect
    uint32_t cpt_jalr_jump = 0; // compteur d'occurences de saut indirect
    uint32_t cpt_jalr_ret = 0; // compteur d'occurences de saut indirect
		//28/03
    uint32_t cpt_bb = 0; // compteur de basic bloc
    uint32_t liste_pred[length]; // liste de précédences de taille au maximum la taille du programme
    
	/*
    fstream memoryfile;
    memoryfile.open(argv[2],ios_base::out); // default is 'in' mode
    if (!memoryfile.is_open()) {
        // display : unable to read file
        cerr << "Error : unable to open file " << argv[2] << endl;
        return(-1);
    }
	*/
	//uint32_t wfi_alert =0; //Added AZ //27/04/21
    for (uint32_t i = 0; i < program.size(); i++){
        current_iaddress = program.at(i).address;//+1048576;
        instruction = program.at(i).instruction_code;        
        opcode = (instruction & 0x0000007F);
        flow_discontinuity = (opcode == 0x67) || (opcode == 0x63) || (opcode == 0x6F);//|| (opcode == 0x73); //Date : 06/12/21 //AZ // Detect ecal and ebreak ...
        if (flow_discontinuity) {
            disasm_inst(buf, sizeof(buf), rv32, current_iaddress, instruction);
            cout << "0x" << hex << current_iaddress << " " << buf << endl;  
            // JAL instruction ??
            if (opcode == 0x6F){
                check++;
                iaddress_space |= current_iaddress;
                cpt_jal++;                
				// get immediate value
                /*imm = (instruction & 0x80000000) ? 0xFFF00000 : 0x0;
                imm += (instruction & 0x00100000) >> 9;
                imm += (instruction & 0x7FE00000) >> 20;
                imm += (instruction & 0x000FF000);
                discontinuity_iaddress = current_iaddress + (int32_t) imm;
                discontinuity_iaddress_idx = discontinuity_iaddress >> 2;
                block_taken = next_block(discontinuity_iaddress_idx, &program);
                block_taken_iaddress = program.at(block_taken).address;
                block_taken_instruction = program.at(block_taken).instruction_code;
                */// Compute Rd
                Rd = (instruction >> 7) & 0x0000001F;
                #ifdef _DEBUG
                if (Rd != 0x1){
                	cpt_jal_jump++;                
                    cout << "\tjump (jal) -> " << endl;
                } else {
                	cpt_jal_call++;
                    cout << "\tcall -> " << endl;
                }
                #endif
                //cout << "Check #" << dec << check << ": iaddress = 0x" << hex << current_iaddress << " / instruction = 0x" << hex << instruction << " / next block (jump) = 0x" << hex << (block_taken_iaddress - current_iaddress) << " / next block (not taken) = NaN" << endl;
                if (Rd == 0x1){ // JAL rd, xxx avec rd = 0x1 (i.e call)
                    check++;
                    /*discontinuity_iaddress = current_iaddress + 4;
                    discontinuity_iaddress_idx = discontinuity_iaddress >> 2;
                    block_taken = next_block(discontinuity_iaddress_idx, &program);
                    block_taken_iaddress = program.at(block_taken).address;
                    block_taken_instruction = program.at(block_taken).instruction_code;
                    cout << "Check #" << dec << check << ": return address = 0x" << hex << discontinuity_iaddress << " / instruction = NaN / next block (call) = 0x" << hex << (block_taken_iaddress - current_iaddress) << " / next block (not taken) = NaN" << endl;*/
                }
            }    
            // branch instruction ?? 
            if (opcode == 0x63){
                check++;
                cpt_branch++;                
                // follow taken branch
                /*imm = (instruction & 0x80000000) ? 0xFFFFF000 : 0x0;
                imm += (instruction & 0x00000080) << 4;
                imm += (instruction & 0x7E000000) >> 20;
                imm += (instruction & 0x00000F00) >> 7;
                discontinuity_iaddress = current_iaddress + (int32_t) imm;
                discontinuity_iaddress_idx = discontinuity_iaddress >> 2;
                #ifdef _DEBUG
                cout << "\ttaken -> " << endl;
                #endif
                block_taken = next_block(discontinuity_iaddress_idx, &program);
                block_taken_iaddress = program.at(block_taken).address;
                block_taken_instruction = program.at(block_taken).instruction_code;

                // follow not taken branch
                #ifdef _DEBUG
                cout << "\tnot taken -> " << endl;
                #endif
                next_iaddress = current_iaddress + 4;
                next_iaddress_idx = next_iaddress >> 2;
                block_not_taken = next_block(next_iaddress_idx, &program);
                block_not_taken_iaddress = program.at(block_not_taken).address;
                block_not_taken_instruction = program.at(block_not_taken).instruction_code;

                cout << "Check #" << dec << check << ": iaddress = 0x" << hex << current_iaddress << " / instruction = 0x" << hex << instruction << " / next block (taken) = 0x" << hex << (block_taken_iaddress - current_iaddress) << " / next block (not taken) = 0x" << hex << (block_not_taken_iaddress - current_iaddress) << endl;
                */
                }
            // JALR instruction ?? (can be RET instruction when Rs = 0x1)
            if (opcode == 0x67){
                check++;
                cpt_jalr++;                
                Rs = (instruction & 0x000F8000) >> 15;
                #ifdef _DEBUG
                if (Rs != 0x1){
                    cout << "\tjump (not a return) -> " << endl;
                    cpt_jalr_jump++;
		            /*if (Rd != 0x1){
		                cout << "\tjump (jalr) " << endl;
		            } else {
	                    cout << "\tcall (jalr) " << endl;            
		            }*/
                } else {
                    cout << "\treturn -> " << endl;
                    cpt_jalr_ret++;
                }
                #endif
        	}
		}
	}	
    return(0);
}
