#include <stdio.h>
#include <math.h>

float max(float a,float b) //create max function for later use
{
	if(a>=b)
		return a;
	else
		return b;		
}

float min(float a,float b)//create min function for later use
{
	if(a<=b)
		return a;
	else
		return b;		
}

float own_gauss (float X,float sigma,float C)
{
    float divident = pow((C-X), 2.0);
    float divisor = 2.0 * pow(sigma,2.0);
    float result = exp(-divident / divisor);
    return result;
}

float own_trap(float X,float a,float b,float c,float d)//create own_trap function
{
    float result;
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
}

float own_tri(float X,float a,float b,float c) //create own_tri function
{
float result = own_trap(X,a,b,b,c);
return result;
}

// main function start
int main(void) 
{

// input  
float service;
float food;


printf("Enter the number of service: ");
scanf("%f", &service); 
printf("Enter the number of food: ");
scanf("%f", &food); 

//Stage 1: fuzzification
float service_poor = own_gauss(service, 1.5, 0);
float service_good = own_gauss(service, 1.5, 5);
float service_excellent = own_gauss(service, 1.5, 0);
//printf("%f\n%f\n%f\n",service_poor,service_good,service_excellent);
float food_rancid = own_trap(food, -2, 0, 1, 3);
float food_delicious = own_trap(food, 7, 9, 10, 12);
//printf("%f\n%f\n", food_rancid,food_delicious);      

float X[ 101 ]; /* X = 0:0.01:10*/
X[0]=0;
   int i,j;
   /* creating X array */         
   for ( i = 0; i <=100; i++ )
   {
      X[ i+1] = X[ i ] + 0.1; /* element setting */
   }
   /* output X array */ 
   for (j = 0; j <= 100; j++ )
   {
      //printf("X[%d] = %f\n", j, X[j] );
   }

//% output universal set  
float Y[ 301 ]; 
Y[0]=0;
   for ( i = 0; i <= 300; i++ )
   {
      Y[ i+1] = Y[i] + 0.1; 
   }
   for (j = 0; j <= 300; j++ )
   {
      //printf("Y[%d] = %f\n", j, Y[j] );
   }

float cheap[ 301 ]; 
   for ( i = 0; i <= 300; i++ )
   {
      cheap[ i ] = own_tri(Y[i], 0, 5, 10);
   }
   for (j = 0; j <= 300; j++ )
   {
      //printf("cheap[%d] = %f\n", j, cheap[j] );
   }

float average[301];
   for ( i = 0; i <= 300; i++ )
   {
      average[ i ] = own_tri(Y[i], 10, 15, 20);
   }
   for (j = 0; j <= 300; j++ )
   {
      //printf("average[%d] = %f\n", j, average[j] );
   }
   
float generous[301];
   for ( i = 0; i <= 300; i++ )
   {
      generous[i] = own_tri(Y[i], 20, 25, 30);
   }
   for (j = 0; j <= 300; j++ )
   {
      //printf("generous[%d] = %f\n", j, generous[j] );
   }

//% Stage 2: compute disjunctive premises (or)
float trigger_r1 = max(service_poor, food_rancid);
float trigger_r2 = service_good;
float trigger_r3 = max(service_excellent, food_delicious);
//printf("\n%f\n""%f\n""%f\n", trigger_r1,trigger_r2,trigger_r3);

// Stage 3: implication
float r1_out[301];
for (i=0;i<=300;i++)
{
    r1_out[i] = min(trigger_r1,cheap[i]);
    //printf("r1_out[%d]=%f\n",i,r1_out[i]);
}

float r2_out[301];
for (i=0;i<=300;i++)
{
    r2_out[i] = min(trigger_r2,average[i]);
    //printf("r2_out[%d]=%f\n",i,r2_out[i]);
}

float r3_out[301];
for (i=0;i<=300;i++)
{
    r3_out[i] = min(trigger_r3,generous[i]);
    //printf("r3_out[%d]=%f\n",i,r3_out[i]);
}

// Stage 4: aggregation
float aggregated[301]; //aggregation
for (i=0;i<=300;i++)
{
    aggregated[i]= max(max(r1_out[i], r2_out[i]), r3_out[i]);
    //printf("aggregated[%d]=%f\n",i,aggregated[i]);
}

//Stage 5: defuzzification

float integration_sum;
float aggregated_sum;
float result;
for (i=0;i<=300;i++)
{
    integration_sum+=aggregated[i] * Y[i];
    aggregated_sum+=aggregated[i];
}
result = integration_sum/aggregated_sum;
//printf("result=%f",result);

//result and variable printing together
printf("=\n");
printf("input service=%f\nintput food=%f\n",service,food);
printf("\noutput tip=%f\n",result);

printf("\n\n*Result and varialbes printing for checking\n");
printf("X[0]=%f\n",X[0]);
printf("X[50]=%f\n",X[50]);
printf("X[100]=%f\n",X[100]);
printf("Y[0]=%f\n",Y[0]);
printf("Y[150]=%f\n",Y[150]);
printf("Y[300]=%f\n",Y[300]);
printf("service_poor=%f\n",service_poor);
printf("service_good=%f\n",service_good);
printf("service_excellent=%f\n",service_excellent);
printf("food_rancid=%f\n",food_rancid);
printf("food_delicious=%f\n",food_delicious);
printf("cheap[0]=%f\n",cheap[0]);
printf("cheap[150]=%f\n",cheap[150]);
printf("cheap[300]=%f\n",cheap[300]);
printf("average[0]=%f\n",average[0]);
printf("average[150]=%f\n",average[150]);
printf("average[300]=%f\n",average[300]);
printf("generous[0]=%f\n",generous[0]);
printf("generous[150]=%f\n",generous[150]);
printf("generous[300]=%f\n",generous[300]);
printf("trigger_r1=%f\n",trigger_r1);
printf("trigger_r2=%f\n",trigger_r2);
printf("trigger_r3=%f\n",trigger_r3);
printf("r1_out[0]=%f\n",r1_out[0]);
printf("r1_out[150]=%f\n",r1_out[150]);
printf("r1_out[300]=%f\n",r1_out[300]);
printf("r2_out[0]=%f\n",r2_out[0]);
printf("r2_out[150]=%f\n",r2_out[150]);
printf("r2_out[300]=%f\n",r2_out[300]);
printf("r3_out[0]=%f\n",r3_out[0]);
printf("r3_out[150]=%f\n",r3_out[150]);
printf("r3_out[300]=%f\n",r3_out[300]);
printf("aggregated[0]=%f\n",aggregated[0]);
printf("aggregated[150]=%f\n",aggregated[150]);
printf("aggregated[300]=%f\n",aggregated[300]);
printf("integration_sum=%f\n",integration_sum);
printf("aggregated_sum=%f\n",aggregated_sum);

return 0;
}
