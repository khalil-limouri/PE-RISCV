.global  _start

# Start a special section called .text.prologue making it
# allocatable and executable
.section .text.prologue, "ax"

_start:
j _init

_fail:
li t0,0xFFFFFFF0
sw a0,0(t0)
j _fail
# when CPU is in this infinte loop, main return was failed
# and error code is in a0 register and store at address 0xFFFFFF0

_success:
li t0,0xFFFFFFF0
sw a0,0(t0)
j _success
# when CPU is in this infinte loop, main return was success
# and zero is in a0 register and store at address 0xFFFFFF0

_init:
li   sp,0x3FFFF # stack pointer = last ram address
andi sp,sp,0xFFFFFFFC # stack pointer = align modulo 4
jal  main
beq  a0,zero,_success
j    _fail

