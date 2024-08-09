	.file	"main.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
# GNU C17 ('corev-openhw-gcc-ubuntu2204-20240114') version 14.0.0 20240106 (experimental) (riscv32-corev-elf)
#	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

# GGC heuristics: --param ggc-min-expand=30 --param ggc-min-heapsize=4096
# options passed: -mabi=ilp32 -misa-spec=20191213 -march=rv32i -fomit-frame-pointer
	.text
	.align	2
	.globl	fct1
	.type	fct1, @function
fct1:
	addi	sp,sp,-32	#,,
	sw	a0,28(sp)	# a, a
	sw	a1,24(sp)	# b, b
	sw	a2,20(sp)	# c, c
	sw	a3,16(sp)	# d, d
	sw	a4,12(sp)	# e, e
	sw	a5,8(sp)	# f, f
	sw	a6,4(sp)	# g, g
	sw	a7,0(sp)	# h, h
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a4,28(sp)		# tmp142, a
	lw	a5,24(sp)		# tmp143, b
	add	a4,a4,a5	# tmp143, _1, tmp142
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,20(sp)		# tmp144, c
	add	a4,a4,a5	# tmp144, _2, _1
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,16(sp)		# tmp145, d
	add	a4,a4,a5	# tmp145, _3, _2
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,12(sp)		# tmp146, e
	add	a4,a4,a5	# tmp146, _4, _3
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,8(sp)		# tmp147, f
	add	a4,a4,a5	# tmp147, _5, _4
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,4(sp)		# tmp148, g
	add	a4,a4,a5	# tmp148, _6, _5
# main.c:5: 	return(a+b+c+d+e+f+g+h);
	lw	a5,0(sp)		# tmp149, h
	add	a5,a4,a5	# tmp149, _15, _6
# main.c:6: }
	mv	a0,a5	#, <retval>
	addi	sp,sp,32	#,,
	jr	ra		#
	.size	fct1, .-fct1
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16	#,,
	sw	ra,12(sp)	#,
# main.c:10: 	fct1(1, 2, 3, 4, 5, 6, 7, 8);
	li	a7,8		#,
	li	a6,7		#,
	li	a5,6		#,
	li	a4,5		#,
	li	a3,4		#,
	li	a2,3		#,
	li	a1,2		#,
	li	a0,1		#,
	call	fct1		#
# main.c:11: 	return 0;
	li	a5,0		# _3,
# main.c:12: }
	mv	a0,a5	#, <retval>
	lw	ra,12(sp)		#,
	addi	sp,sp,16	#,,
	jr	ra		#
	.size	main, .-main
	.ident	"GCC: ('corev-openhw-gcc-ubuntu2204-20240114') 14.0.0 20240106 (experimental)"
	.section	.note.GNU-stack,"",@progbits
