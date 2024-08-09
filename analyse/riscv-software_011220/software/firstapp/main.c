#include "func.h"

char uninitialised_global[4096];
char initialised_global[]="DEADBEAF\n";

const int acste=0x55AA55AA;

volatile unsigned int *stdout_uint=(void*)0xFFFF0000;

int main() {
  int a=0xDEADBEAF;
  int b=a/2;
  register unsigned int gp asm("gp");

  int c=afunction(a,acste);

  int i=0;
  for (i=0;i<10;i++)
  {
    uninitialised_global[4000+i]=initialised_global[i];
    (*stdout_uint)=uninitialised_global[4000+i];
  }

  (*stdout_uint)=0x12345678;
  (*stdout_uint)=(unsigned int)uninitialised_global;
  (*stdout_uint)=(unsigned int)initialised_global;
  (*stdout_uint)=gp;

  return 0;
}



