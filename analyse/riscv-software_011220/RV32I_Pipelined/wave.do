onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rv32i_tb/RV32I_top_1/clk_i
add wave -noupdate /rv32i_tb/RV32I_top_1/resetn_i
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/Instruction_IFID_i
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/Instruction_IDEX_i
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/Instruction_EXMEM_i
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/Instruction_MEMWB_i
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ALU_zero_i
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ALU_lt_i
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/PC_select_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ALUSrc1_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ALUSrc2_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ALUControl_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ForwardA_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/ForwardB_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/MemWrite_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/MemRead_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/WB_select_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/RegWrite_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/PCWrite_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IFIDWrite_o
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IFID_Rs1_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IFID_Rs2_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/Stall_select_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/PipelinedControl_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_ControlEXE_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_ControlMEM_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_ControlWB_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_Rs1_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_Rs2_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_MemRead_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/IDEXE_Rd_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/EXMEM_ControlMEM_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/EXMEM_ControlWB_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/EXMEM_RegWrite_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/EXMEM_Rd_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/MEMWB_ControlWB_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/MEMWB_RegWrite_s
add wave -noupdate /rv32i_tb/RV32I_top_1/RV32I_Pipelined_controlpath_1/MEMWB_Rd_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/pc_next_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/pc_plus4_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/pc_counter_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/instruction_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/instruction_mem/mem_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/data_mem/mem_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/register_file_1/regs_file_s
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IFID_instruction
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IFID_pc_counter
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IFID_pc_plus4
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_instruction
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_imm
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_rs2_data
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_rs1_data
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_pc_counter
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/IDEXE_pc_plus4
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_instruction
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_rs2_data
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_alu
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_alu_lt
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_alu_zero
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_imm
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/EXMEM_pc_plus4
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/MEMWB_rd
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/MEMWB_alu
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/MEMWB_mem_data
add wave -noupdate -radix hexadecimal /rv32i_tb/RV32I_top_1/RV32I_Pipelined_datapath_1/MEMWB_pc_plus4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {299775 ps} 0}
configure wave -namecolwidth 603
configure wave -valuecolwidth 87
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {312375 ps}
