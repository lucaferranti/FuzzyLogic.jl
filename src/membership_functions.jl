"""
Abstract type for membership functions.
"""
abstract type AbstractMembershipFunction end

@doc raw"""
Generalized Bell membership function ``\frac{1}{1+\vert\frac{x-c}{a}\vert^{2b}}``.
"""
struct GeneralizedBellMF{T <: Real, S <: Real} <: AbstractMembershipFunction
    "Width of the curve, the bigger the wider."
    a::T
    "Slope of the curve, the bigger the steeper."
    b::S
    "Center of the curve."
    c::T
end
((; a, b, c)::GeneralizedBellMF)(x) = 1 / (1 + abs((x - c) / a)^(2b))

"""
Gaussian membership function ``e^{-\\frac{(x-μ)²}{2σ²}}``.
"""
struct GaussianMF{T <: Real}
    "mean ``μ``."
    mu::T
    "standard deviation ``σ``."
    sig::T
end
((; mu, sig)::GaussianMF)(x) = exp(-(x - mu)^2 / (2sig^2))

"""
Triangular membership function.
"""
struct TriangularMF{T <: Real}
    "left foot."
    a::T
    "peak."
    b::T
    "right foot."
    c::T
end
((; a, b, c)::TriangularMF)(x) = max(min((x - a) / (b - a), (c - x) / (c - b)), 0)

"""
Trapezoidal membership function.
"""
struct TrapezoidalMF{T <: Real}
    "left foot."
    a::T
    "left shoulder."
    b::T
    "right shoulder."
    c::T
    "right foot."
    d::T
end
((; a, b, c, d)::TrapezoidalMF)(x) = max(min((x - a) / (b - a), 1, (d - x) / (d - c)), 0)

"""
Linear membership function.
If ``a < b``, it is increasing (S-shaped), otherwise it is decreasing (Z-shaped).
"""
struct LinearMF{T <: Real}
    "foot."
    a::T
    "shoulder."
    b::T
end
((; a, b)::LinearMF)(x) = max(min((a - x) / (a - b), 1), 0)

@doc raw"""
Sigmoid membership function ``\frac{1}{1+e^{-a(x-c)}}``.
"""
struct SigmoidMF{T <: Real}
    "parameter controlling the slope of the curve."
    a::T
    "center of the slope."
    c::T
end
((; a, c)::SigmoidMF)(x) = 1 / (1 + exp(-a * (x - c)))

"""
Difference of two sigmoids. See also [`SigmoidMF`](@ref).
"""
struct DifferenceSigmoidMF{T <: Real}
    "slope of the first sigmoid."
    a1::T
    "center of the first sigmoid."
    c1::T
    "slope of the second sigmoid."
    a2::T
    "center of the second sigmoid."
    c2::T
end
function ((; a1, c1, a2, c2)::DifferenceSigmoidMF)(x)
    return max(min(1 / (1 + exp(-a1 * (x - c1))) - 1 / (1 + exp(-a2 * (x - c2))), 1), 0)
end

"""
Product of two sigmoids. See also [`SigmoidMF`](@ref).
"""
struct ProductSigmoidMF{T <: Real}
    "slope of the first sigmoid."
    a1::T
    "center of the first sigmoid."
    c1::T
    "slope of the second sigmoid."
    a2::T
    "center of the second sigmoid."
    c2::T
end
function ((; a1, c1, a2, c2)::ProductSigmoidMF)(x)
    return 1 / ((1 + exp(-a1 * (x - c1))) * (1 + exp(-a2 * (x - c2))))
end
