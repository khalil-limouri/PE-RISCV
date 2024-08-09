#define _ASM
#define STR(x) #x
#define EXPAND(x) STR(x)
#define r_type_insn(_f7, _rs2, _rs1, _f3, _rd, _opc) \
(((_f7) << 25) | ((_rs2) << 20) | ((_rs1) << 15) | ((_f3) << 12) | ((_rd) << 7) | ((_opc) << 0))

#define VADD(_rd, _rs1, _rs2) \
r_type_insn(0b0000000, _rs2, _rs1, 0b000, _rd, 0b0110011)

int main(void) {
	int a = 2;
	int b = 3;
	int c;
#ifndef _ASM
	c = a + b;
#else
	asm (	
		"lw	a4,-20(s0);"
  		"lw	a5,-24(s0);"
// 		"add	a5,a4,a5;"
//		".word 0x00F707B3;"  
		".word " EXPAND(VADD(15, 14, 15)) ";"
		"sw	a5,-28(s0)");
#endif
	if (c == 5) 
		return(0);
	else
		return(1);
}

