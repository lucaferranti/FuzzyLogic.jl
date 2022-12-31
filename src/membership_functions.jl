# Membership functions

"""
An interval representing the domain of a given variable.
"""
struct Domain{T <: Real}
    "lower bound."
    low::T
    "upper bound."
    high::T
end
Base.show(io::IO, d::Domain) = print(io, '[', low(d), ", ", high(d), ']')
low(d::Domain) = d.low
high(d::Domain) = d.high
Base.in(x::Number, d::Domain) = low(d) <= x <= high(d)

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
(mf::GeneralizedBellMF)(x) = 1 / (1 + abs((x - mf.c) / mf.a)^(2mf.b))

"""
Gaussian membership function ``e^{-\\frac{(x-μ)²}{2σ²}}``.
"""
struct GaussianMF{T <: Real} <: AbstractMembershipFunction
    "mean ``μ``."
    mu::T
    "standard deviation ``σ``."
    sig::T
end
(mf::GaussianMF)(x) = exp(-(x - mf.mu)^2 / (2mf.sig^2))

"""
Triangular membership function.
"""
struct TriangularMF{T <: Real} <: AbstractMembershipFunction
    "left foot."
    a::T
    "peak."
    b::T
    "right foot."
    c::T
end
(mf::TriangularMF)(x) = max(min((x - mf.a) / (mf.b - mf.a), (mf.c - x) / (mf.c - mf.b)), 0)

"""
Trapezoidal membership function.
"""
struct TrapezoidalMF{T <: Real} <: AbstractMembershipFunction
    "left foot."
    a::T
    "left shoulder."
    b::T
    "right shoulder."
    c::T
    "right foot."
    d::T
end
function (mf::TrapezoidalMF)(x)
    return max(min((x - mf.a) / (mf.b - mf.a), 1, (mf.d - x) / (mf.d - mf.c)), 0)
end

"""
Linear membership function.
If ``a < b``, it is increasing (S-shaped), otherwise it is decreasing (Z-shaped).
"""
struct LinearMF{T <: Real} <: AbstractMembershipFunction
    "foot."
    a::T
    "shoulder."
    b::T
end
(mf::LinearMF)(x) = max(min((x - mf.a) / (mf.b - mf.a), 1), 0)

@doc raw"""
Sigmoid membership function ``\frac{1}{1+e^{-a(x-c)}}``.
"""
struct SigmoidMF{T <: Real} <: AbstractMembershipFunction
    "parameter controlling the slope of the curve."
    a::T
    "center of the slope."
    c::T
end
(mf::SigmoidMF)(x) = 1 / (1 + exp(-mf.a * (x - mf.c)))

"""
Difference of two sigmoids. See also [`SigmoidMF`](@ref).
"""
struct DifferenceSigmoidMF{T <: Real} <: AbstractMembershipFunction
    "slope of the first sigmoid."
    a1::T
    "center of the first sigmoid."
    c1::T
    "slope of the second sigmoid."
    a2::T
    "center of the second sigmoid."
    c2::T
end
function (mf::DifferenceSigmoidMF)(x)
    return max(min(1 / (1 + exp(-mf.a1 * (x - mf.c1))) -
                   1 / (1 + exp(-mf.a2 * (x - mf.c2))), 1), 0)
end

"""
Product of two sigmoids. See also [`SigmoidMF`](@ref).
"""
struct ProductSigmoidMF{T <: Real} <: AbstractMembershipFunction
    "slope of the first sigmoid."
    a1::T
    "center of the first sigmoid."
    c1::T
    "slope of the second sigmoid."
    a2::T
    "center of the second sigmoid."
    c2::T
end
function (mf::ProductSigmoidMF)(x)
    return 1 / ((1 + exp(-mf.a1 * (x - mf.c1))) * (1 + exp(-mf.a2 * (x - mf.c2))))
end
