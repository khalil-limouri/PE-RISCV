#include<stdio.h>


int main(void) 
{
    int ch, a;
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
     case 3:
     a = ch + 3;
	break;
     case 4:
     a = ch + 4;	
        break;
     case 5:
     a = ch + 5;	
        break;
     case 6:
     a = ch + 6;
        break;
     default:
          printf("\n %d : Invalid Product Selection", a);
          break;
 
    }
    return 0;
}
