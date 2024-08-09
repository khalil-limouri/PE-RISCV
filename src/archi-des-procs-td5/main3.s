	.file	"main3.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	fct2
	.type	fct2, @function
fct2:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	addi	s0,sp,64
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	a3,-48(s0)
	sw	a4,-52(s0)
	sw	a5,-56(s0)
	sw	a6,-60(s0)
	sw	a7,-64(s0)
	lw	a4,-36(s0)
	lw	a5,-40(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a4,0(s0)
	lw	a5,4(s0)
	add	a5,a4,a5
	sw	a5,-24(s0)
	lw	a4,-36(s0)
	lw	a5,-40(s0)
	add	a4,a4,a5
	lw	a5,-44(s0)
	add	a4,a4,a5
	lw	a5,-48(s0)
	add	a4,a4,a5
	lw	a5,-52(s0)
	add	a4,a4,a5
	lw	a5,-56(s0)
	add	a4,a4,a5
	lw	a5,-60(s0)
	add	a4,a4,a5
	lw	a5,-64(s0)
	add	a4,a4,a5
	lw	a5,0(s0)
	add	a4,a4,a5
	lw	a5,4(s0)
	add	a4,a4,a5
	lw	a5,-20(s0)
	add	a4,a4,a5
	lw	a5,-24(s0)
	add	a5,a4,a5
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	fct2, .-fct2
	.align	1
	.globl	fct3
	.type	fct3, @function
fct3:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	addi	s0,sp,64
	mv	a5,a0
	sb	a5,-33(s0)
	addi	sp,sp,-16
	addi	a5,sp,8
	addi	a5,a5,15
	srli	a5,a5,4
	slli	a5,a5,4
	sw	a5,-20(s0)
	li	a5,10
	sw	a5,4(sp)
	li	a5,9
	sw	a5,0(sp)
	li	a7,8
	li	a6,7
	li	a5,6
	li	a4,5
	li	a3,4
	li	a2,3
	li	a1,2
	li	a0,1
	call	fct2
	mv	a5,a0
	mv	a4,a5
	lw	a5,-20(s0)
	sw	a4,0(a5)
	nop
	addi	sp,s0,-64
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	fct3, .-fct3
	.ident	"GCC: ('corev-openhw-gcc-ubuntu2204-20240114') 14.0.0 20240106 (experimental)"
	.section	.note.GNU-stack,"",@progbits
