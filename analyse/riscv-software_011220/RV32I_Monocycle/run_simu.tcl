restart
run 60ns
force -deposit sim:/RV32I_tb/RV32I_top_1/RV32I_Monocycle_datapath_1/register_file_1/regs_file_s(1) 00000000000000000000000000000011 0
force -deposit sim:/RV32I_tb/RV32I_top_1/RV32I_Monocycle_datapath_1/register_file_1/regs_file_s(2) 00000000000000000000000000000001 0
run -all
