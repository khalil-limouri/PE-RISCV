#include<stdio.h>


int main(void) 
{
    int ch, a=0;
    printf("\n\tMENU CARD Enter Your choice  : ");
    scanf("%d",&ch);
    switch(ch)
    {
    case 1:
     a = ch + 1;
	break;
     case 2:
     a = ch + 2;
        break;
     default:
          printf("\nInvalid Product Selection");
          break;
 
    }
    return 0;
}
