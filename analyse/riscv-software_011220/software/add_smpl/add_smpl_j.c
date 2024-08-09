#define AZ _ASM
#define STR(x) #x
#define EXPAND(x) STR(x)
#define r_type_insn(_f7, _rs2, _rs1, _f3, _rd, _opc) \
(((_f7) << 25) | ((_rs2) << 20) | ((_rs1) << 15) | ((_f3) << 12) | ((_rd) << 7) | ((_opc) << 0))


int fct1 ( int a, int b)
{return (a+b) ;
}

void main()
{

int c=0;
int d=3;
int e=5;

d =1+3;

c=fct1(d,e);

    asm (    
        "jal	zero, 0x1006c8"
);

asm (
	        "lw	a7,0(sp)"
);
asm (
	        "lw	s2,0(sp)"
);

}
