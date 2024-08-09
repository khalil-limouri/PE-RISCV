for program in $1; do
	echo "Compile $program"
	/opt/corev/bin/riscv32-corev-elf-gcc \
		 \
		-static -mabi=ilp32 -march=rv32im -Wall -pedantic \
		 \
		-I asm \
		-I bsp \
		-o programs/$program/$program.elf \
		-nostartfiles \
		programs/$program/*.c \
		programs/$program/*.h \
		-T bsp/link.ld \
		-L bsp \
		-lcv-verif

	/opt/corev/bin/riscv32-corev-elf-objcopy -O verilog \
		programs/$program/$program.elf \
		programs/$program/$program.hex

	/opt/corev/bin/riscv32-corev-elf-readelf -a programs/$program/$program.elf > programs/$program/$program.readelf

	/opt/corev/bin/riscv32-corev-elf-objdump \
		-d \
		-M no-aliases \
		-M numeric \
		-S \
		programs/$program/$program.elf > programs/$program/$program.objdump

	/opt/corev/bin/riscv32-corev-elf-objdump \
		-d \
		-S \
		-M no-aliases \
		-M numeric \
		-l \
		programs/$program/$program.elf | bin/objdump2itb - > programs/$program/$program.itb
done;
