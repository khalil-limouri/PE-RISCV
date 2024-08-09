## COMPILE BSP

``` bash
cd bsp
make \
	RISCV=/opt/corev \
	RISCV_PREFIX=riscv32-corev-elf- \
	RISCV_EXE_PREFIX=/opt/corev/bin/riscv32-corev-elf- \
	RISCV_MARCH=rv32im \
	RISCV_CC=gcc \
	RISCV_CFLAGS="" \
	all
```

## COMPILE PROGRAM mycode.c
``` bash
/opt/corev/bin/riscv32-corev-elf-gcc \
	 \
	-Os -g -static -mabi=ilp32 -march=rv32im -Wall -pedantic \
	 \
	-I asm \
	-I bsp \
	-o programs/mycode/mycode.elf \
	-nostartfiles \
	programs/mycode/mycode.c \
	-T bsp/link.ld \
	-L bsp \
	-lcv-verif

```



## GENERATE HEX FILE
``` bash
/opt/corev/bin/riscv32-corev-elf-objcopy -O verilog \
	programs/mycode/mycode.elf \
	programs/mycode/mycode.hex
```

## EXECUTE READELF AND SAVE OUTPUT
``` bash
/opt/corev/bin/riscv32-corev-elf-readelf -a programs/mycode/mycode.elf > programs/mycode/mycode.readelf
```

## EXECUTE OBJDUMP AND SAVE OUTPUT
``` bash
/opt/corev/bin/riscv32-corev-elf-objdump \
	-d \
	-M no-aliases \
	-M numeric \
	-S \
	programs/mycode/mycode.elf > programs/mycode/mycode.objdump
```

## GENERATE ITB FORMAT FROM OBJDUMP
``` bash
/opt/corev/bin/riscv32-corev-elf-objdump \
    	-d \
        -S \
	-M no-aliases \
	-M numeric \
        -l \
	programs/mycode/mycode.elf | bin/objdump2itb - > programs/mycode/mycode.itb
```
