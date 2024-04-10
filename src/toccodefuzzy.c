#include <stdio.h>
#include <math.h>

double own_gauss(double x, double sigma, double mean) {
    return exp(-pow(x - mean, 2) / (2 * pow(sigma, 2)));
}

void own_trap(const double *X, int length, double a, double b, double c, double d, double *mf) {
    for (int i = 0; i < length; i++) {
        if (X[i] >= b && X[i] <= c) {
            mf[i] = 1;
        } else if (X[i] > a && X[i] < b) {
            mf[i] = (X[i] - a) / (b - a);
        } else if (X[i] > c && X[i] < d) {
            mf[i] = (d - X[i]) / (d - c);
        } else {
            mf[i] = 0;
        }
    }
}

void own_tri(const double *X, int length, double a, double b, double c, double *mf) {
    own_trap(X, length, a, b, b, c, mf);
}

double own_centroid(const double *y, const double *C, int length) {
    double numerator = 0.0;
    double denominator = 0.0;
    for (int i = 0; i < length - 1; i++) {
        double delta_y = y[i+1] - y[i];
        numerator += (y[i] * C[i] + y[i+1] * C[i+1]) / 2.0 * delta_y;
        denominator += (C[i] + C[i+1]) / 2.0 * delta_y;
    }
    return numerator / denominator;
}



#include <stdio.h>
#include <stdlib.h>



int main() {
    double service = 3; // Example value
    double food = 8; // Example value

 
    double service_poor = own_gauss(service, 1.5, 0);
    double service_good = own_gauss(service, 1.5, 5);
    double service_excellent = own_gauss(service, 1.5, 10); 

    double food_rancid = own_gauss(food, 1.5, -2); 
    double food_delicious = own_gauss(food, 1.5, 9); 


    // Print example values
    printf("Service Poor: %f, Food Delicious: %f\n", service_poor, food_delicious);


    
    return 0;
}