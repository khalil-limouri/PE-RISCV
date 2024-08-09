#include<stdio.h>

void f1(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}

void f2(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*10));
}

void f3(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*25));
}

void f4(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*50));
}

void f5(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}

void f6(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}

int main(void) 
{
    int ch,qty;
    printf("\n\tMENU CARD");
    printf("\n\t\t1.        Rs:15");
    printf("\n\t\t2.           Rs:10");
    printf("\n\t\t3.   Rs:25");
    printf("\n\t\t4.    Rs:50");
    printf("\n\t\t5.    Rs:50");
    printf("\n\t\t6.    Rs:50");
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
        f4(&qty);        
        break;
     case 6:
        f4(&qty);        
        break;
     default:
          printf("\nInvalid Product Selection");
          break;
 
    }
    return 0;
}
