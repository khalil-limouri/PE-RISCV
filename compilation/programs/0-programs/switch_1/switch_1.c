#include<stdio.h>

void f1(int *p1)
{
        scanf("%d",p1);
        printf("\nTotal amount : %d",((*p1)*15));
}


int main(void) 
{
    int ch,qty;
    printf("\n\tMENU CARD");
    printf("\n\t\t1.        Rs:15");
    scanf("%d",&ch);
    switch(ch)
    {
    case 1:
        f1(&qty);
        break;
    }
    return 0;
}
