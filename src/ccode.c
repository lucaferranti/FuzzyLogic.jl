#include <stdio.h>
  double own_Tri(double X,double a,double b,double c)//create own Triangular function
{
    double result;
    if (0<=X & X<a)
    {
        result=0;
    }
    if (a<=X & X<b)
    {
        result=(X-a)/(b-a);
    }
    if (b<=X & X<c)
    {
        result=(X-c)/(b-c);
    }
    if (c<=X)
    {
        result=0;
    }
    return result;
}
int main(void) {
    double a=0;
    double b=5;
    double c=10;
    double X=3;
    double y=own_Tri(X,a,b,c);
    printf("%f",y);
}