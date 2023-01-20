# Membership functions

abstract type AbstractMembershipFunction end

"""
Generalized Bell membership function ``\\frac{1}{1+\\vert\\frac{x-c}{a}\\vert^{2b}}``.

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = GeneralizedBellMF(2, 4, 5)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = GaussianMF(5.0, 1.5)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = TriangularMF(3, 5, 7)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = TrapezoidalMF(1, 3, 7, 9)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = LinearMF(2, 8)
```
"""
struct LinearMF{T <: Real} <: AbstractMembershipFunction
    "foot."
    a::T
    "shoulder."
    b::T
end
(mf::LinearMF)(x) = max(min((x - mf.a) / (mf.b - mf.a), 1), 0)

"""
Sigmoid membership function ``\\frac{1}{1+e^{-a(x-c)}}``.

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = SigmoidMF(2, 5)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = DifferenceSigmoidMF(5, 2, 5, 7)
```
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

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = ProductSigmoidMF(2, 3, -5, 8)
```
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

"""
S-shaped membership function.

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = SShapeMF(1, 8)
```
"""
struct SShapeMF{T <: Real} <: AbstractMembershipFunction
    "foot."
    a::T
    "shoulder."
    b::T
end
function (s::SShapeMF)(x::T) where {T <: Real}
    x <= s.a && return zero(float(T))
    x >= s.b && return one(float(T))
    x >= (s.a + s.b) / 2 && return 1 - 2 * ((x - s.b) / (s.b - s.a))^2
    return 2 * ((x - s.a) / (s.b - s.a))^2
end

"""
Z-shaped membership function.

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = ZShapeMF(3, 7)
```
"""
struct ZShapeMF{T <: Real} <: AbstractMembershipFunction
    "shoulder."
    a::T
    "foot."
    b::T
end
function (z::ZShapeMF)(x::T) where {T <: Real}
    x <= z.a && return one(float(T))
    x >= z.b && return zero(float(T))
    x >= (z.a + z.b) / 2 && return 2 * ((x - z.b) / (z.b - z.a))^2
    return 1 - 2 * ((x - z.a) / (z.b - z.a))^2
end

"""
Π-shaped membership function.

### Fields

$(TYPEDFIELDS)

### Example

```julia
mf = PiShapeMF(1, 4, 5, 10)
```
"""
struct PiShapeMF{T <: Real} <: AbstractMembershipFunction
    "left foot."
    a::T
    "left shoulder."
    b::T
    "right shoulder."
    c::T
    "right foot."
    d::T
end
function (p::PiShapeMF)(x::T) where {T <: Real}
    (x <= p.a || x >= p.d) && return zero(float(T))
    p.b <= x <= p.c && return one(float(T))
    x <= (p.a + p.b) / 2 && return 2 * ((x - p.a) / (p.b - p.a))^2
    x <= p.b && return 1 - 2 * ((x - p.b) / (p.b - p.a))^2
    x <= (p.c + p.d) / 2 && return 1 - 2 * ((x - p.c) / (p.d - p.c))^2
    return 2 * ((x - p.d) / (p.d - p.c))^2
end

struct ConstantSugenoMF{T} <: AbstractMembershipFunction
    c::T
end
(csmf::ConstantSugenoMF)(inputs) = csmf.c
(csmf::ConstantSugenoMF)(; inputs...) = csmf.c
Base.show(io::IO, csmf::ConstantSugenoMF) = print(io, csmf.c)

struct LinearSugenoMF{T} <: AbstractMembershipFunction
    coeffs::Dictionary{Symbol, T}
    offset::T
end
function Base.:(==)(m1::LinearSugenoMF, m2::LinearSugenoMF)
    m1.offset == m2.offset && m1.coeffs == m2.coeffs
end
function (fsmf::LinearSugenoMF)(inputs)
    sum(val * fsmf.coeffs[name] for (name, val) in pairs(inputs)) + fsmf.offset
end
(fsmf::LinearSugenoMF)(; inputs...) = fsmf(inputs)

function Base.show(io::IO, lsmf::LinearSugenoMF)
    started = false
    for (var, c) in pairs(lsmf.coeffs)
        iszero(c) && continue
        if started
            print(io, c < 0 ? " - " : " + ", isone(abs(c)) ? "" : abs(c), var)
        else
            print(io, isone(c) ? "" : c, var)
        end
        started = true
    end
    if started
        iszero(lsmf.offset) || print(io, lsmf.offset < 0 ? " - " : " + ", abs(lsmf.offset))
    else
        print(io, lsmf.offset)
    end
end
