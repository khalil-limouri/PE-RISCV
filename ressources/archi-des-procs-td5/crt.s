	.section .start;
	.globl start;



start:
	#  registers init
	mv t0,zero
	mv t1,zero
	mv t2,zero
	mv t3,zero
   

	# Setup sp and gp

	#la  gp, _gp
        .option push
        .option norelax
        la gp, __global_pointer$
        .option pop

	la  sp, _sp

	# Clear uninitialized (zeroed) data sections
  
	la  t1,__bss_start
	la  t2,__bss_end


clr_lp:
	sw    zero,0(t1)               
	addi  t1,t1,4
	bltu  t1,t2,clr_lp          
	nop 

	# Copy initialized data sections from ROM into RAM
	la      t1,__data_start
	la      t2,__data_end
	la      t3,__text_end

cp_lp: 
	lw      t0,0(t3)              
	sw      t0,0(t1)              
	addi    t1,t1,4
	addi    t3,t3,4
	bgtu    t2,t1,cp_lp          
	nop
	j main
	.end start
