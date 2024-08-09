	.file	"main4.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	global
	.bss
	.align	2
	.type	global, @object
	.size	global, 512
global:
	.zero	512
	.globl	initialized_global
	.section	.sdata,"aw"
	.align	2
	.type	initialized_global, @object
	.size	initialized_global, 4
initialized_global:
	.word	1431677610
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
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	addi	s0,sp,80
	li	a5,1
	sw	a5,-20(s0)
	li	a5,2
	sw	a5,-24(s0)
	li	a5,3
	sw	a5,-28(s0)
	li	a5,4
	sw	a5,-32(s0)
	li	a5,5
	sw	a5,-36(s0)
	li	a5,6
	sw	a5,-40(s0)
	li	a5,7
	sw	a5,-44(s0)
	li	a5,8
	sw	a5,-48(s0)
	li	a5,9
	sw	a5,-52(s0)
	li	a5,10
	sw	a5,-56(s0)
	lui	a5,%hi(initialized_global)
	li	a4,305418240
	addi	a4,a4,1656
	sw	a4,%lo(initialized_global)(a5)
	li	a5,9
	sw	a5,4(sp)
	li	a5,8
	sw	a5,0(sp)
	li	a7,7
	li	a6,6
	li	a5,5
	li	a4,4
	li	a3,3
	li	a2,2
	li	a1,1
	li	a0,0
	call	fct2
	mv	a4,a0
	lui	a5,%hi(global)
	addi	a5,a5,%lo(global)
	sw	a4,40(a5)
	li	a5,0
	mv	a0,a5
	lw	ra,76(sp)
	lw	s0,72(sp)
	addi	sp,sp,80
	jr	ra
	.size	main, .-main
	.ident	"GCC: ('corev-openhw-gcc-ubuntu2204-20240114') 14.0.0 20240106 (experimental)"
	.section	.note.GNU-stack,"",@progbits
