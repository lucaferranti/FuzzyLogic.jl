print("hello world")
a = 2
print(a)
n = 1234
typeof(n)
π
typeof(π)
5 * 3
1 == 1

pi = 3.14
"abc" ^ 3
# Define a linear function
function linearFunction(x)
    a = 2 # Coefficient of x
    b = 3 # Constant term
    return a*x + b
end
linearFunction(3)
# Triangular Membership Function
function triangularMembership(x, a, b, c)
    if x < a || x > c
        return 0
    elseif x < b
        return (x - a) / (b - a)
    else
        return (c - x) / (c - b)
    end
end

# Trapezoidal Membership Function
function trapezoidalMembership(x, a, b, c, d)
    if x < a || x > d
        return 0
    elseif x >= b && x <= c
        return 1
    elseif x < b
        return (x - a) / (b - a)
    else
        return (d - x) / (d - c)
    end
end

# Gaussian Membership Function
function gaussianMembership(x, μ, σ)
    return exp(-0.5 * ((x - μ) / σ)^2)
end

add(x::Int, y::String) = repeat(y, x)
add(x::String, y::Int) = repeat(x, y)
add(x::String, y::String) = x * y
add(x::Int, y::Int) = x + y 