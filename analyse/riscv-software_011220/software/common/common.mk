# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

COMMON_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

COMMON_SRCS = $(wildcard $(COMMON_DIR)/*.c)
INCS := -I$(COMMON_DIR)

# ARCH = rv32im # to disable compressed instructions
ARCH ?= rv32i
 PROGRAM_CFLAGS = -fverbose-asm -fomit-frame-pointer $(CPPFLAGS)
ifdef PROGRAM
PROGRAM_C := $(PROGRAM).c
endif

SRCS = $(COMMON_SRCS) $(PROGRAM_C) $(EXTRA_SRCS)

C_SRCS = $(filter %.c, $(SRCS))
ASM_SRCS = $(filter %.S, $(SRCS))

#CC = riscv64-unknown-linux-gnu-gcc
CC= riscv32-unknown-linux-gnu-gcc

OBJCOPY ?= $(subst gcc,objcopy,$(wordlist 1,1,$(CC)))
OBJDUMP ?= $(subst gcc,objdump,$(wordlist 1,1,$(CC)))

LINKER_SCRIPT ?= $(COMMON_DIR)/link.ld
CRT ?= $(COMMON_DIR)/crt0.S
CFLAGS ?= -march=$(ARCH) -mabi=ilp32 -static -mcmodel=medany -Wall -g -O0\
	-fvisibility=hidden -nostartfiles -ffreestanding $(PROGRAM_CFLAGS)
#AZ // disabled -nostdlib for AES memcpy
OBJS := ${C_SRCS:.c=.o} ${ASM_SRCS:.S=.o} ${CRT:.S=.o}
DEPS = $(OBJS:%.o=%.d)

ifdef PROGRAM
OUTFILES := $(PROGRAM).elf $(PROGRAM).vmem $(PROGRAM).bin $(PROGRAM).dis $(PROGRAM).hex
else
OUTFILES := $(OBJS)
endif

all: $(OUTFILES)

$(PROGRAM).elf: $(OBJS) $(LINKER_SCRIPT)
	$(CC) $(CFLAGS) -T $(LINKER_SCRIPT) $(OBJS) -o $@ $(LIBS)

%.dis: %.elf
	$(OBJDUMP) -fhSD $^ > $@

# Note: this target requires the srecord package to be installed.
# XXX: This could be replaced by objcopy once
# https://sourceware.org/bugzilla/show_bug.cgi?id=19921
# is widely available.
%.vmem: %.bin
	srec_cat $^ -binary -offset 0x0000 --fill 0x00 --within $^ -binary --range-pad 4 -byte-swap 4 -o $@ -vmem
#Note for Memcpy I used  srec_cat $^ -binary  --fill 0x00 --within $^ -binary --range-padding 4 -o $@ -vmem (the last #option) because I had error message with proposition:
#srec_cat: memcpy.vmem: 82: The VMem output format uses 32-bit data, but
#   unaligned data is present. Use a "--fill 0xNN --within <input>
#    --range-padding 4" filter to fix this problem.
# For the others We need to use again : 	srec_cat $^ -binary -offset 0x0000 -byte-swap 4 -o $@ -vmem
#srec_cat $^ -binary -offset 0x0000 --fill 0x00 --within $^ -binary --range-pad 4 -byte-swap 4 -o $@ -vmem
%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

%.o: %.c
	$(CC) $(CFLAGS) -MMD -c $(INCS) -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -MMD -c $(INCS) -o $@ $<

$(PROGRAM).hex: $(PROGRAM).bin
	../bin2hex.py $< > $@
clean:
	$(RM) -f $(OBJS) $(DEPS)

distclean: clean
	$(RM) -f $(OUTFILES)
