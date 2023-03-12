# Fuzzy inference system options

abstract type AbstractFISSetting end
## T-Norms

abstract type AbstractAnd <: AbstractFISSetting end

"""
Minimum T-norm defining conjuction as ``A ∧ B = \\min(A, B)``.
"""
struct MinAnd <: AbstractAnd end
(ma::MinAnd)(x, y) = min(x, y)

"""
Product T-norm defining conjuction as ``A ∧ B = AB``.
"""
struct ProdAnd <: AbstractAnd end
(pa::ProdAnd)(x, y) = x * y

"""
Lukasiewicz T-norm defining conjuction as ``A ∧ B = \\max(0, A + B - 1)``.
"""
struct LukasiewiczAnd <: AbstractAnd end
(la::LukasiewiczAnd)(x, y) = max(0, x + y - 1)

"""
Drastic T-norm defining conjuction as ``A ∧ B = \\min(A, B)`` is ``A = 1`` or ``B = 1`` and
``A ∧ B = 0`` otherwise.
"""
struct DrasticAnd <: AbstractAnd end
function (da::DrasticAnd)(x::T, y::S) where {T <: Real, S <: Real}
    TS = promote_type(T, S)
    isone(x) && return TS(y)
    isone(y) && return TS(x)
    zero(TS)
end

"""
Nilpotent T-norm defining conjuction as ``A ∧ B = \\min(A, B)`` when ``A + B > 1`` and
``A ∧ B = 0`` otherwise.
"""
struct NilpotentAnd <: AbstractAnd end
function (na::NilpotentAnd)(x::T, y::S) where {T <: Real, S <: Real}
    m = min(x, y)
    x + y > 1 && return m
    return zero(m)
end

"""
Hamacher T-norm defining conjuction as ``A ∧ B = \\frac{AB}{A + B - AB}`` if ``A \\neq 0 \\neq B``
and ``A ∧ B = 0`` otherwise.
"""
struct HamacherAnd <: AbstractAnd end
function (ha::HamacherAnd)(x::T, y::S) where {T <: Real, S <: Real}
    iszero(x) && iszero(y) && return zero(float(promote_type(T, S)))
    (x * y) / (x + y - x * y)
end

"""
Einstein T-norm defining conjuction as ``A ∧ B = \\frac{AB}{2 - A - B + AB}``.
"""
struct EinsteinAnd <: AbstractAnd end
(ha::EinsteinAnd)(x::Real, y::Real) = (x * y) / (2 - x - y + x * y)

## S-Norms

abstract type AbstractOr <: AbstractFISSetting end

"""
Maximum S-norm defining disjunction as ``A ∨ B = \\max(A, B)``.
"""
struct MaxOr <: AbstractOr end
(mo::MaxOr)(x, y) = max(x, y)

"""
Probabilistic sum S-norm defining disjunction as ``A ∨ B = A + B - AB``.
"""
struct ProbSumOr <: AbstractOr end
(pso::ProbSumOr)(x, y) = x + y - x * y

"""
Bounded sum S-norm defining disjunction as ``A ∨ B = \\min(1, A + B)``.
"""
struct BoundedSumOr <: AbstractOr end
(la::BoundedSumOr)(x, y) = min(1, x + y)

"""
Drastic S-norm defining disjunction as ``A ∨ B = \\min(1, A + B)``.
"""
struct DrasticOr <: AbstractOr end
function (da::DrasticOr)(x::T, y::S) where {T <: Real, S <: Real}
    TS = promote_type(T, S)
    iszero(x) && return TS(y)
    iszero(y) && return TS(x)
    one(TS)
end

"""
Nilpotent S-norm defining disjunction as ``A ∨ B = \\max(A, B)`` when ``A + B < 1`` and
``A ∧ B = 1`` otherwise.
"""
struct NilpotentOr <: AbstractOr end
function (na::NilpotentOr)(x::T, y::S) where {T <: Real, S <: Real}
    m = max(x, y)
    x + y < 1 && return m
    return one(m)
end

"""
Einstein S-norm defining disjunction as ``A ∨ B = \\frac{A + B}{1 + AB}``.
"""
struct EinsteinOr <: AbstractOr end
(ha::EinsteinOr)(x, y) = (x + y) / (1 + x * y)

"""
Hamacher S-norm defining conjuction as ``A ∨ B = \\frac{A + B - AB}{1 - AB}`` if ``A \\neq 1 \\neq B``
and ``A ∨ B = 1`` otherwise.
"""
struct HamacherOr <: AbstractOr end
function (ha::HamacherOr)(x::T, y::S) where {T <: Real, S <: Real}
    isone(x) && isone(y) && return one(float(promote_type(T, S)))
    (x + y - 2 * x * y) / (1 - x * y)
end

## Implication

abstract type AbstractImplication <: AbstractFISSetting end

"""
Minimum implication defined as ``A → B = \\min(A, B)``.
"""
struct MinImplication <: AbstractImplication end
(mini::MinImplication)(x, y) = min(x, y)

"""
Product implication defined as ``A → B = AB``.
"""
struct ProdImplication <: AbstractImplication end
(pim::ProdImplication)(x, y) = x * y

## Aggregation

abstract type AbstractAggregator <: AbstractFISSetting end

"""
Aggregator that combines fuzzy rules output by taking their maximum.
"""
struct MaxAggregator <: AbstractAggregator end
(ma::MaxAggregator)(x, y) = max(x, y)

"""
Aggregator that combines fuzzy rules output by taking their probabilistic sum.
See also [`ProbSumOr`](@ref).
"""
struct ProbSumAggregator <: AbstractAggregator end
(psa::ProbSumAggregator)(x, y) = x + y - x * y

## Defuzzification

abstract type AbstractDefuzzifier <: AbstractFISSetting end

"""
Centroid defuzzifier. Given the aggregated output function ``f`` and the output
variable domain ``[a, b]`` the defuzzified output is the centroid computed as

```math
\\frac{∫_a^bxf(x)\\textrm{d}x}{∫_a^bf(x)\\textrm{d}x}.
```

### Parameters

$(TYPEDFIELDS)

## Algorithm

The integrals are computed numerically using the trapezoidal rule.
"""
struct CentroidDefuzzifier <: AbstractDefuzzifier
    "number of subintervals for integration, default 100."
    N::Int
end
CentroidDefuzzifier() = CentroidDefuzzifier(100)
function (cd::CentroidDefuzzifier)(y, dom::Domain{T})::float(T) where {T}
    dx = (high(dom) - low(dom)) / cd.N
    _trapz(dx, LinRange(low(dom), high(dom), cd.N + 1) .* y) / _trapz(dx, y)
end

"""
Bisector defuzzifier. Given the aggregated output function ``f`` and the output
variable domain ``[a, b]`` the defuzzified output is the value ``t ∈ [a, b]`` that divides
the area under ``f`` into two equal parts. That is

```math
∫_a^tf(x)\\textrm{d}x = ∫_t^af(x)\\textrm{d}x.
```

### Parameters

$(TYPEDFIELDS)

## Algorithm

The domain is partitioned into N equal subintervals. For each subinterval endpoint, the left
and right area are approximated using the trapezoidal rule.
The end point leading to the best approximation is the final result.

"""
struct BisectorDefuzzifier <: AbstractDefuzzifier
    "number of subintervals for integration, default 100."
    N::Int
end
BisectorDefuzzifier() = BisectorDefuzzifier(100)
function (bd::BisectorDefuzzifier)(y, dom::Domain{T})::float(T) where {T}
    area_left = zero(T)
    h = (high(dom) - low(dom)) / bd.N
    area_right = _trapz(h, y)
    cand = LinRange(low(dom), high(dom), bd.N + 1)
    i = firstindex(y)
    while area_left < area_right
        trap = (y[i] + y[i + 1]) * h / 2
        area_left += trap
        area_right -= trap
        i += 1
    end
    (y[i - 1] + y[i]) * h / 2 >= area_left - area_right ? cand[i] : cand[i - 1]
end

"""
Left maximum defuzzifier. Returns the smallest value in the domain for which the membership function
reaches its maximum.

### Parameters

$(TYPEDFIELDS)

"""
Base.@kwdef struct LeftMaximumDefuzzifier <: AbstractDefuzzifier
    "number of subintervals, default 100."
    N::Int = 100
    "absolute tolerance to determine if a value is maximum, default `eps(Float64)`."
    tol::Float64 = eps(Float64)
end
function (lmd::LeftMaximumDefuzzifier)(y, dom::Domain{T}) where {T}
    res = float(low(dom))
    maxval = first(y)
    for (xi, yi) in zip(LinRange(low(dom), high(dom), lmd.N + 1), y)
        if yi > maxval + lmd.tol
            res = xi
            maxval = yi
        end
    end
    res
end

"""
Right maximum defuzzifier. Returns the largest value in the domain for which the membership function
reaches its maximum.

### Parameters

$(TYPEDFIELDS)

"""
Base.@kwdef struct RightMaximumDefuzzifier <: AbstractDefuzzifier
    "number of subintervals, default 100."
    N::Int = 100
    "absolute tolerance to determine if a value is maximum, default `eps(Float64)`."
    tol::Float64 = eps(Float64)
end
function (lmd::RightMaximumDefuzzifier)(y, dom::Domain{T}) where {T}
    res = float(low(dom))
    maxval = first(y)
    for (xi, yi) in zip(LinRange(low(dom), high(dom), lmd.N + 1), y)
        if yi >= maxval - lmd.tol
            res = xi
            maxval = yi
        end
    end
    res
end

"""
Mean of maxima defuzzifier. Returns the mean of the values in the domain for which the
membership function reaches its maximum.

### Parameters

$(TYPEDFIELDS)
"""
Base.@kwdef struct MeanOfMaximaDefuzzifier <: AbstractDefuzzifier
    "number of subintervals, default 100."
    N::Int = 100
    "absolute tolerance to determine if a value is maximum, default `eps(Float64)`."
    tol::Float64 = eps(Float64)
end
function (lmd::MeanOfMaximaDefuzzifier)(y, dom::Domain{T}) where {T}
    res = zero(float(T))
    maxcnt = 0
    maxval = first(y)
    for (xi, yi) in zip(LinRange(low(dom), high(dom), lmd.N + 1), y)
        if yi - maxval > lmd.tol # reset mean calculation
            res = xi
            maxval = yi
            maxcnt = 1
        elseif abs(yi - maxval) <= lmd.tol
            res += xi
            maxcnt += 1
        end
    end
    return res / maxcnt
end

_trapz(dx, y) = (2sum(y) - first(y) - last(y)) * dx / 2

abstract type Type2Defuzzifier <: AbstractDefuzzifier end

"""
Karnik-Mendel type-reduction/defuzzification algorithm for Type-2 fuzzy systems.

### Parameters

$(TYPEDFIELDS)

# Extended help

The algorithm was introduced in

- Karnik, Nilesh N., and Jerry M. Mendel. ‘Centroid of a Type-2 Fuzzy Set’. Information Sciences 132, no. 1–4 (February 2001): 195–220
"""
Base.@kwdef struct KarnikMendelDefuzzifier <: Type2Defuzzifier
    "number of subintervals for integration, default 100."
    N::Int = 100
    "maximum number of iterations, default 100."
    maxiter::Int = 100
    "absolute tolerance for stopping iterations"
    atol::Float64 = 1e-6
end

function (kmd::KarnikMendelDefuzzifier)(w, dom::Domain{T})::float(T) where {T}
    x = LinRange(low(dom), high(dom), length(w))
    m = map(mid, w)
    x0 = sum(xi * mi for (xi, mi) in zip(x, m)) / sum(m)
    xl = x0
    xr = x0
    idx = searchsortedlast(x, x0)
    @inbounds for _ in 1:(kmd.maxiter)
        num = zero(eltype(m))
        den = zero(eltype(m))
        for i in firstindex(x):idx
            den += sup(w[i])
            num += sup(w[i]) * x[i]
        end
        for i in (idx + 1):length(x)
            den += inf(w[i])
            num += inf(w[i]) * x[i]
        end

        cand = num / den
        if abs(cand - xl) <= kmd.atol
            xl = cand
            break
        end
        xl = cand
        idx = searchsortedlast(x, xl)
    end

    @inbounds for _ in 1:(kmd.maxiter)
        num = zero(eltype(m))
        den = zero(eltype(m))
        for i in firstindex(x):idx
            den += inf(w[i])
            num += inf(w[i]) * x[i]
        end
        for i in (idx + 1):length(x)
            den += sup(w[i])
            num += sup(w[i]) * x[i]
        end

        cand = num / den
        if abs(cand - xr) <= kmd.atol
            xr = cand
            break
        end
        xr = cand
        idx = searchsortedlast(x, xr)
    end
    return (xl + xr) / 2
end

"""
Enhanced Karnik-Mendel type-reduction/defuzzification algorithm for Type-2 fuzzy systems.

### Parameters

$(TYPEDFIELDS)

# Extended help

The algorithm was introduced in

- Wu, D. and J.M. Mendel, "Enhanced Karnik-Mendel algorithms," IEEE Transactions on Fuzzy Systems, vol. 17, pp. 923-934. (2009)
"""
Base.@kwdef struct EKMDefuzzifier <: Type2Defuzzifier
    "number of subintervals for integration, default 100."
    N::Int = 100
    "maximum number of iterations, default 100."
    maxiter::Int = 100
end

function (ekmd::EKMDefuzzifier)(w, dom::Domain{T})::float(T) where {T}
    Np = length(w)
    x = LinRange(low(dom), high(dom), Np)
    k = round(Int, Np / 2.4)
    a = sum(x[i] * sup(w[i]) for i in 1:k) + sum(x[i] * inf(w[i]) for i in (k + 1):Np)
    b = sum(sup(w[i]) for i in 1:k) + sum(inf(w[i]) for i in (k + 1):Np)
    yl = a / b
    @inbounds for _ in 1:(ekmd.maxiter)
        knew = searchsortedlast(x, yl)
        k == knew && break
        s = sign(knew - k)
        a += s * sum(x[i] * diam(w[i]) for i in (min(k, knew) + 1):max(k, knew))
        b += s * sum(diam(w[i]) for i in (min(k, knew) + 1):max(k, knew))
        yl = a / b
        k = knew
    end

    k = round(Int, Np / 1.7)
    a = sum(x[i] * inf(w[i]) for i in 1:k) + sum(x[i] * sup(w[i]) for i in (k + 1):Np)
    b = sum(inf(w[i]) for i in 1:k) + sum(sup(w[i]) for i in (k + 1):Np)
    yr = a / b
    @inbounds for _ in 1:(ekmd.maxiter)
        knew = searchsortedlast(x, yr)
        k == knew && break
        s = sign(knew - k)
        a -= s * sum(x[i] * diam(w[i]) for i in (min(k, knew) + 1):max(k, knew))
        b -= s * sum(diam(w[i]) for i in (min(k, knew) + 1):max(k, knew))
        yr = a / b
        k = knew
    end

    return (yl + yr) / 2
end

"""
Defuzzifier for type-2 inference systems using Iterative Algorithm with Stopping Condition (IASC).

### PARAMETERS

$(TYPEDFIELDS)

# Extended help

The algorithm was introduced in

- Duran, K., H. Bernal, and M. Melgarejo, "Improved iterative algorithm for computing the generalized centroid of an interval type-2 fuzzy set," Annual Meeting of the North American Fuzzy Information Processing Society, pp. 190-194. (2008)
"""
Base.@kwdef struct IASCDefuzzifier <: Type2Defuzzifier
    "number of subintervals for integration, default 100."
    N::Int = 100
end
function (iasc::IASCDefuzzifier)(w, dom::Domain{T})::float(T) where {T}
    Np = length(w)
    x = LinRange(low(dom), high(dom), Np)
    a = sum(xi * inf(wi) for (xi, wi) in zip(x, w))
    b = sum(inf, w)
    yl = last(x)
    @inbounds for (xi, wi) in zip(x, w)
        a += xi * diam(wi)
        b += diam(wi)
        c = a / b
        c > yl && break
        yl = c
    end

    a = sum(xi * sup(wi) for (xi, wi) in zip(x, w))
    b = sum(sup, w)
    yr = first(x)
    @inbounds for (xi, wi) in zip(x, w)
        a -= xi * diam(wi)
        b -= diam(wi)
        c = a / b
        c < yr && break
        yr = c
    end

    return (yl + yr) / 2
end

"""
Defuzzifier for type-2 inference systems using Iterative Algorithm with Stopping Condition (IASC).

### PARAMETERS

$(TYPEDFIELDS)

# Extended help

The algorithm was introduced in

- Wu, D. and M. Nie, "Comparison and practical implementations of type-reduction algorithms for type-2 fuzzy sets and systems," Proceedings of FUZZ-IEEE, pp. 2131-2138 (2011)
"""
Base.@kwdef struct EIASCDefuzzifier <: Type2Defuzzifier
    "number of subintervals for integration, default 100."
    N::Int = 100
end
function (eiasc::EIASCDefuzzifier)(w, dom::Domain{T})::float(T) where {T}
    Np = length(w)
    x = LinRange(low(dom), high(dom), Np)
    a = sum(xi * inf(wi) for (xi, wi) in zip(x, w))
    b = sum(inf, w)
    yl = last(x)
    @inbounds for (xi, wi) in zip(x, w)
        a += xi * diam(wi)
        b += diam(wi)
        c = a / b
        c > yl && break
        yl = c
    end

    a = sum(xi * inf(wi) for (xi, wi) in zip(x, w))
    b = sum(inf, w)
    yr = first(x)
    @inbounds for i in reverse(eachindex(x))
        a += x[i] * diam(w[i])
        b += diam(w[i])
        c = a / b
        c < yr && break
        yr = c
    end

    return (yl + yr) / 2
end
