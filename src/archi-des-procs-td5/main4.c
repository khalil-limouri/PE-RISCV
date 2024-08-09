int global[128];
int initialized_global=0x5555AAAA;
int fct2( int a, int b, int c, int d, int e, int f ,int g, int h, int i, int j)
{
int x;
int y;
x=a+b;
y=i+j;
return(a+b+c+d+e+f+g+h+i+j+x+y);
}
int long main()
{
int A=1;
int B=2;
int C=3;
int D=4;
int E=5;
int F=6;
int G=7;
int H=8;
int I=9;
int J=10;
initialized_global=0x12345678;
global[10]=fct2(0,1,2,3,4,5,6,7,8,9);
return(0);
}
