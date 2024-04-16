function to_c(mf::TriangularMF)
    """
    #include <math.h> 

    double triangularMF(double x) {
        const double a = $(mf.a);
        const double b = $(mf.b);
        const double c = $(mf.c);

        if (x < a || x > c) {
            return 0.0;  
        } else if (x >= a && x <= b) {
            return (x - a) / (b - a);  
        } else if (x > b && x <= c) {
            return (c - x) / (c - b);  
        } else {
            return 0.0; 
        }
    }
    """
end

function to_c(mf::GaussianMF)
    """
    #include <math.h>

    double gaussianMF(double x) {
        const double mean = $(mf.mean);
        const double sigma = $(mf.sigma);
        return exp(-pow((x - mean), 2) / (2 * pow(sigma, 2)));
    }
    """
end

function to_c(mf::TrapezoidalMF)
    """
    #include <math.h>

       double trapezoidalMF(double x) {
        const double a = $(mf.a);
        const double b = $(mf.b);
        const double c = $(mf.c);
        const double d = $(mf.d);

        if (x < a || x > d) {
            return 0.0;   
        } else if (x >= a && x < b) {
            return (x - a) / (b - a);  
        } else if (x >= b && x <= c) {
            return 1.0;  
        } else if (x > c && x <= d) {
            return (d - x) / (d - c); 
        } else {
            return 0.0; 
        }
    }
    """
end

tri_mf = TriangularMF(0.0, 5.0, 10.0)
c_code = to_c(tri_mf)
println(c_code)

gaussian_mf = GaussianMF(5.0, 1.5)
c_code = to_c(gaussian_mf)
println(c_code)

trapezoidal_mf = TrapezoidalMF(0.0, 5.0, 8.0, 10.0)
c_code = to_c(trapezoidal_mf)
println(c_code)


