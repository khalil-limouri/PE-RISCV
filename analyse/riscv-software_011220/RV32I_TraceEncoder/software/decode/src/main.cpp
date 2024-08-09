#include <fstream>
#include <iostream>
#include <vector>
#include "riscv-disas.h"
#include "definitions.h"
#include "decoder-algorithm-public.h"

using namespace std;

int main(int argc, char **argv)
{
    if (argc != 3) {
        // display help
        cerr << "Error  : bad arguments => " << argv[0] << " <hex filename> <trace encoder output filename" << endl;
        return -1;
    }

    fstream hexfile;
    hexfile.open(argv[1]); // default is 'in' mode
    if (!hexfile.is_open()) {
        // display : unable to read file
        cerr << "Error : unable to open file " << argv[1] << endl;
        return(-1);
    }
    
    // read instructions
    vector<tInstr> instructions;
    u_int32_t PC = 0;
    u_int32_t instruction;
    while(hexfile.good()){
        hexfile >> hex >> instruction;    
        tInstr AnInstruction;
        AnInstruction.address = (PC++) << 2;
        AnInstruction.instruction_code = instruction;
        instructions.push_back(AnInstruction);
    }

    // close file
    hexfile.close();

    char buf[128] = { 0 };
    for(uint32_t i = 0; i < instructions.size(); i++){
        disasm_inst(buf, sizeof(buf), rv32, (uint64_t) instructions[i].address, instructions[i].instruction_code);
        cout << "0x" << hex << instructions[i].address <<  " , " << buf << endl;
    }

    // read ite file to decode trace
    fstream itefile;
    itefile.open(argv[2]); // default is 'in' mode
    if (!itefile.is_open()) {
        // display : unable to read file
        cerr << "Error : unable to open file " << argv[2] << endl;
        return(-1);
    }
    
    // create decoder
    te_decoder_state_t *decoder = te_open_trace_decoder(NULL, &instructions, rv32);

    uint64_t packet;
    while(itefile.good()){
        itefile >> hex >> packet;    
        te_inst_t APacket;
        // TODO update te_inst_t from data read
        
    }

    // close file
    itefile.close();

    // delete decoder
    free(decoder);
    return(0);
}
