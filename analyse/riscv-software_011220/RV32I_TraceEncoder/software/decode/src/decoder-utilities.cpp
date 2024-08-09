#include "decoder-algorithm-public.h"
#include "riscv-disas.h"
#include "definitions.h"
#include <vector>
#include <iostream>

using namespace std;

unsigned te_get_instruction(
    void * const user_data,
    const te_address_t address,
    rv_inst * const instruction){

    vector<tInstr> *instructions = (vector<tInstr> *) user_data;
    uint32_t index = address >> 2;
    if (index < instructions->size()){
        tInstr AnInstruction = instructions->at(index);
        *instruction = (rv_inst) AnInstruction.instruction_code;
        return 0;
    } else {
        return 1;
    }
}

void te_advance_decoded_pc(
    void * const user_data,
    const te_address_t old_pc,
    const te_address_t new_pc,
    const te_decoded_instruction_t * const new_instruction){

    vector<tInstr> *instructions = (vector<tInstr> *) user_data;
    uint32_t index_old = old_pc >> 2;
    uint32_t index_new = new_pc >> 2;
    if ((index_old < instructions->size()) && (index_old < instructions->size())){
        tInstr OldInstruction = instructions->at(index_old);
        tInstr NewInstruction = instructions->at(index_new);
        char buf[128] = { 0 };
        disasm_inst(buf, sizeof(buf), rv32, (uint64_t) OldInstruction.address, OldInstruction.instruction_code);
        cout << "Discontinuity from " << buf << " to ";
        disasm_inst(buf, sizeof(buf), rv32, (uint64_t) NewInstruction.address, NewInstruction.instruction_code);
        cout << buf << endl;     
    } else {
        cerr << "Error : unknown pc values (old or new) : " << hex << old_pc << "," << hex << new_pc << endl;
    }
}
