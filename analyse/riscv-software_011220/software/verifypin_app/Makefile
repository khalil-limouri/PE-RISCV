PRGM=verifypin
SRC=$(wildcard *.c) $(wildcard *.s) $(wildcard *.S) ../start.S
OBJ=$(patsubst %.c,%.o,$(patsubst %.s,%.o,$(patsubst %.S,%.o,$(SRC))))
ASM=$(OBJ:%.o=%.asm) $(PRGM).asm $(PRGM).canonical.asm

OS_NAME := $(shell uname -s | tr A-Z a-z)

ifeq ($(OS_NAME), darwin)
	PREFIX?= riscv64-unknown-elf-
else
	PREFIX?=riscv-none-embed-
endif
GCC=$(PREFIX)gcc
AS=$(PREFIX)as
LD=$(PREFIX)ld
OBJCOPY=$(PREFIX)objcopy
OBJDUMP=$(PREFIX)objdump
#CFLAGS?= -march=rv32i -mabi=ilp32 -nostartfiles -nostdlib -nodefaultlibs -Wl,-T,linker.ld -g -O0
CFLAG?= -march=rv32i -mabi=ilp32 -g -O0
AFLAG?= -march=rv32i -mabi=ilp32
ifeq ($(OS_NAME), darwin)
	LDFLAG?= -melf32lriscv
else
	LDFLAG?=
endif

all: $(PRGM) $(PRGM).bin $(PRGM).hex $(ASM)

%.o: %.c $(wildcard *.h)
	$(GCC) $(CFLAG) -c $< -o $@
%.o: %.S $(wildcard *.h)
	$(GCC) $(CFLAG) -c $< -o $@
%.o: %.s
	$(AS) $(AFLAG) $< -o $@

%.asm: %.o
	$(OBJDUMP) -d -S $< > $@
$(PRGM).asm: $(PRGM)
	$(OBJDUMP) -d -S $< > $@
$(PRGM).canonical.asm: $(PRGM)
	$(OBJDUMP) -d -S --disassembler-options=numeric,no-aliases $< > $@

$(PRGM): $(OBJ) ../linker.ld
	$(LD) $(LDFLAG) -T ../linker.ld $(OBJ) -o $@

$(PRGM).bin: $(PRGM)
	$(OBJCOPY) $< -O binary $@

$(PRGM).hex: $(PRGM).bin
	../bin2hex.py $< > $@

run: $(PRGM).hex
	vsim -work ../../RV32I_Monocycle/rtl -c   -quiet -msgmode both -Grom_init_filename=$< -Gram_init_filename=$< -Gtrace_encoder_filename=$(PRGM).ite -Gstdout_filename=stdout -Gtrace_filename=trace -Gmax_cycles=10000 -Gverbose=0 rv32i_tb -do 'run -all; quit -f'
	../stdout_hex2bin.py stdout

run.gui: $(PRGM).hex
	vsim -work ../../RV32I_Monocycle/rtl -gui -quiet -msgmode both -Grom_init_filename=$< -Gram_init_filename=$< -Gtrace_encoder_filename=$(PRGM).ite -Gstdout_filename=stdout -Gtrace_filename=trace -Gmax_cycles=10000 -Gverbose=0 rv32i_tb

.PHONY: clean
clean:
	rm -f $(OBJ) $(ASM)

.PHONY: mrproper
mrproper: clean
	rm -f $(PRGM) $(PRGM).bin $(PRGM).hex stdout trace
