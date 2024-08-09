#include<stdio.h>

void f1(int *p1)
{
	printf("\nYou have selected Coffee");
        printf("\nEnter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}

void f2(int *p1)
{
	printf("\nYou have selected Tea");
        printf("\nEnter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*10));
}

void f3(int *p1)
{
	printf("\nYou have selected Cold Coffee");
        printf("\nEnter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*25));
}

void f4(int *p1)
{
	printf("\nYou have selected Milk Shake");
        printf("\nEnter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*50));
}

int main(void) 
{
    int ch,qty;
    printf("\n\tMENU CARD");
    printf("\n\t\t1.COFFEE        Rs:15");
    printf("\n\t\t2.TEA           Rs:10");
    printf("\n\t\t3.COLD COFFEE   Rs:25");
    printf("\n\t\t4.MILK SHAKE    Rs:50");
    printf("\n\n Enter Your choice  : ");
    scanf("%d",&ch);
    switch(ch)
    {
    case 1:
        f1(&qty);
        break;
     case 2:
        f2(&qty);     
        break;
     case 3:
        f3(&qty);     
        break;
     case 4:
        f4(&qty);        
        break;
     default:
          printf("\nInvalid Product Selection");
          break;
 
    }
    return 0;
}
