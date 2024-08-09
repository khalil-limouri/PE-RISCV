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

d =e+2;
//Appel d'une fonction //JAL instruction + ret instruction
c=fct1(d,e);


//JAL Instruction (representing J)
    asm (    
        "jal	zero, 0x1006cc"
);


asm (
	        "lw	s2,0(sp)"
);

asm (
	        "lw	s4,0(sp)"
);

int f=0x000664; //Adresse de la fonction fct1
//JALR Instruction
//    	"lw	s3,0(sp);"
    asm (   "lw	a1,4(sp);"
    	    "lw	a0,8(sp);"	
        "jalr	ra,a5, 0x00;"
        "sw	a0,12(sp)"
);
      	
//Basic Block

c=c+3;
e=c+4;
d=c+e;
d=d+1;
e=e+5;

//If conditions

if (e==d)
{
 asm (
	        "lw	a7,8(sp)"
	        );
	        c=d;
}

else if (e<d)
{
 asm (
	        "lw	a7,4(sp)"
	        );
c=e;
}
else if (e>d)
{
 asm (
	        "lw	a7,12(sp)"
	        );
c=c+1;
}

asm (
	        "lw	s2,0(sp)"
);

}
