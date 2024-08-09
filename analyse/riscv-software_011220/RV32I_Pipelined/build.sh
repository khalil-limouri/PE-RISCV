#! /bin/sh
files_list=(RV32I_constants.vhd \
		RV32I_components.vhd \
		mux_comp.vhd \
		demux_comp.vhd \
		sync_mem.vhd \
		register_file.vhd \
		alu.vhd \
		RV32I_Pipelined_datapath.vhd \
		RV32I_Pipelined_controlpath.vhd \
		RV32I_Pipelined_top.vhd \
		../test/RV32I_tb.vhd)

if [ -d ./libs/work ]
then
    vdel -lib ./libs/work/ -all
    vlib ./libs/work
else
    vlib ./libs/work
fi
vmap work ./libs/work 

for file in ${files_list[*]} ; do
    echo "compiling : " $file
    if [ $file="sync_mem.vhd" or $file="alu.vhd"] then
       vcom -2008 -work work ./src/$file
    else
	vcom -93 -work work ./src/$file  
    fi
done
