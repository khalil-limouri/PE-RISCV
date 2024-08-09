	.file	"test.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_a2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	2
.LC0:
	.string	"\nYou have selected Coffee"
	.align	2
.LC1:
	.string	"\nEnter The Qty : "
	.align	2
.LC2:
	.string	"%d"
	.align	2
.LC3:
	.string	"\nTotal amount : %d"
	.text
	.align	1
	.globl	f1
	.type	f1, @function
f1:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	printf
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	lw	a1,-20(s0)
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	scanf
	lw	a5,-20(s0)
	lw	a4,0(a5)
	mv	a5,a4
	slli	a5,a5,4
	sub	a5,a5,a4
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	f1, .-f1
	.section	.rodata
	.align	2
.LC4:
	.string	"\nYou have selected Tea"
	.text
	.align	1
	.globl	f2
	.type	f2, @function
f2:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	printf
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	lw	a1,-20(s0)
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	scanf
	lw	a5,-20(s0)
	lw	a4,0(a5)
	mv	a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,1
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	f2, .-f2
	.section	.rodata
	.align	2
.LC5:
	.string	"\nYou have selected Cold Coffee"
	.text
	.align	1
	.globl	f3
	.type	f3, @function
f3:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	printf
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	lw	a1,-20(s0)
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	scanf
	lw	a5,-20(s0)
	lw	a4,0(a5)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	slli	a5,a5,3
	add	a5,a5,a4
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	f3, .-f3
	.section	.rodata
	.align	2
.LC6:
	.string	"\nYou have selected Milk Shake"
	.text
	.align	1
	.globl	f4
	.type	f4, @function
f4:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	printf
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	lw	a1,-20(s0)
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	scanf
	lw	a5,-20(s0)
	lw	a4,0(a5)
	li	a5,50
	mul	a5,a4,a5
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	printf
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	f4, .-f4
	.section	.rodata
	.align	2
.LC7:
	.string	"\n\tMENU CARD"
	.align	2
.LC8:
	.string	"\n\t\t1.COFFEE        Rs:15"
	.align	2
.LC9:
	.string	"\n\t\t2.TEA           Rs:10"
	.align	2
.LC10:
	.string	"\n\t\t3.COLD COFFEE   Rs:25"
	.align	2
.LC11:
	.string	"\n\t\t4.MILK SHAKE    Rs:50"
	.align	2
.LC12:
	.string	"\n\n Enter Your choice  : "
	.align	2
.LC13:
	.string	"\nInvalid Product Selection"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	printf
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	printf
	lui	a5,%hi(.LC9)
	addi	a0,a5,%lo(.LC9)
	call	printf
	lui	a5,%hi(.LC10)
	addi	a0,a5,%lo(.LC10)
	call	printf
	lui	a5,%hi(.LC11)
	addi	a0,a5,%lo(.LC11)
	call	printf
	lui	a5,%hi(.LC12)
	addi	a0,a5,%lo(.LC12)
	call	printf
	addi	a5,s0,-20
	mv	a1,a5
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	scanf
	lw	a5,-20(s0)
	li	a4,4
	beq	a5,a4,.L6
	li	a4,4
	bgt	a5,a4,.L7
	li	a4,3
	beq	a5,a4,.L8
	li	a4,3
	bgt	a5,a4,.L7
	li	a4,1
	beq	a5,a4,.L9
	li	a4,2
	beq	a5,a4,.L10
	j	.L7
.L9:
	addi	a5,s0,-24
	mv	a0,a5
	call	f1
	j	.L11
.L10:
	addi	a5,s0,-24
	mv	a0,a5
	call	f2
	j	.L11
.L8:
	addi	a5,s0,-24
	mv	a0,a5
	call	f3
	j	.L11
.L6:
	addi	a5,s0,-24
	mv	a0,a5
	call	f4
	j	.L11
.L7:
	lui	a5,%hi(.LC13)
	addi	a0,a5,%lo(.LC13)
	call	printf
	nop
.L11:
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: ('corev-openhw-gcc-ubuntu2004-20211104') 12.0.0 20211020 (experimental)"
