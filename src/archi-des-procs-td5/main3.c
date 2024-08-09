#include <alloca.h>
int fct2( int a, int b, int c, int d, int e, int f ,int g, int h, int i, int j)
{
	int x;
	int y;
	x=a+b;
	y=i+j;
	return(a+b+c+d+e+f+g+h+i+j+x+y);
}
void fct3(unsigned char i){
	unsigned int *ptr;
	ptr=alloca(4);
	*ptr=fct2(1,2,3,4,5,6,7,8,9,10);
}
