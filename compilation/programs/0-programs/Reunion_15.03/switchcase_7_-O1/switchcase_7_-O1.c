#include<stdio.h>

void f1(int *p1)
{
	printf("\nYou have selected Coffee Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}

void f2(int *p1)
{
	printf("\nYou have selected Tea Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*10));
}

void f3(int *p1)
{
	printf("\nYou have selected Cold Coffee Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*25));
}

void f4(int *p1)
{
	printf("\nYou have selected Milk Shake Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*50));
}

void f5(int *p1)
{
	printf("\nYou have selected Milk Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*30));
}

void f6(int *p1)
{
	printf("\nYou have selected Ice Tea Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*35));
}

void f7(int *p1)
{
	printf("\nYou have selected Coffee with Milk Enter The Qty : ");
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*40));
}


int main(void) 
{
    int ch,qty;
    printf("\n\tMENU CARD");
    printf("\n\t\t1.COFFEE        Rs:15");
    printf("\n\t\t2.TEA           Rs:10");
    printf("\n\t\t3.COLD COFFEE   Rs:25");
    printf("\n\t\t4.MILK SHAKE    Rs:50");
    printf("\n\t\t5.MILK        Rs:30");
    printf("\n\t\t6.COFFEE WITH MILK           Rs:35");
    printf("\n\t\t7.ICE TEA    Rs:40");
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
     case 5:
        f5(&qty);     
        break;
     case 6:
        f6(&qty);     
        break;
     case 7:
        f7(&qty);        
        break;
     default:
          printf("\nInvalid Product Selection");
	break;	
    }
    return 0;
}
