# Print Hello World
println("Hello, World!\n")
println("Choose your Fuzzy membership function: \n1-Triangular Membership Function\n2-Trapezoidal Membership Function\n3-Gaussian Membership Function")

Choose = readline()
Choose_int = parse(Int, Choose) # Convert string to integer
println("You have chosen $Choose")

if Choose_int == 1
  println("You have chosen Triangular Membership Function
  #include <stdio.h>
  double own_Tri(double X,double a,double b,double c）
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
    double X=4;
    double y=own_Tri(X,a,b,c);
    }")
elseif Choose_int == 2
  println("You have chosen Trapezoidal Membership Function\n
  double own_trap(double X,double a,double b,double c,double d)//create own_trap function
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
        result=1;
    }
    if (c<=X & X<d)
    {
        result=(X-d)/(c-d);
    }  
    if (d<=X)
    {
        result=0;
    }
    return result;
}")
elseif Choose_int == 3
  println("You have chosen Gaussian Membership Function")
else
  println("Invalid choice.")
end

function to_c(x::TriangularMF)
  """
  The parameters are
  a = $(x.a)
  b = $(x.b)
  c = $(x.c)
 """
end