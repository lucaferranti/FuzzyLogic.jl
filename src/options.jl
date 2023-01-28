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
Hamacher T-norm defining conjuction as ``A ∧ B = \\frac{AB}{A + B - AB}`` if ``A ≂̸ 0 ≂̸ B``
and ``A ∧ B = 0`` otherwise.
"""
struct HamacherAnd <: AbstractAnd end
function (ha::HamacherAnd)(x::T, y::S) where {T <: Real, S <: Real}
    iszero(x) && iszero(y) && return zero(float(promote_type(T, S)))
    (x * y) / (x + y - x * y)
end

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

@doc raw"""
Centroid defuzzifier. Given the aggregated output function ``f`` and the output
variable domain ``[a, b]`` the defuzzified output is the centroid computed as

```math
\frac{∫_a^bxf(x)\textrm{d}x}{∫_a^bf(x)\textrm{d}x}.
```

## Algorithm

The integrals are computed numerically using the trapezoidal rule.
"""
struct CentroidDefuzzifier <: AbstractDefuzzifier
    "number of subintegrals for integration, default 100."
    N::Int
end
CentroidDefuzzifier() = CentroidDefuzzifier(100)
function (cd::CentroidDefuzzifier)(y, dom::Domain{T}, N::Int)::float(T) where {T}
    dx = (high(dom) - low(dom)) / N
    _trapz(dx, LinRange(low(dom), high(dom), N) .* y) / _trapz(dx, y)
end

@doc raw"""
Bisector defuzzifier. Given the aggregated output function ``f`` and the output
variable domain ``[a, b]`` the defuzzified output is the value ``t ∈ [a, b]`` that divides
the area under ``f`` into two equal parts. That is

```math
∫_a^tf(x)\textrm{d}x = ∫_t^af(x)\textrm{d}x.
```

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
function (bd::BisectorDefuzzifier)(f::Function, dom::Domain{T})::float(T) where {T}
    area_left = zero(T)
    area_right = _trapz(f, low(dom), high(dom), bd.N)
    cand = low(dom)
    h = (high(dom) - low(dom)) / bd.N
    while area_left < area_right
        trap = (f(cand) + f(cand + h)) * h / 2
        area_left += trap
        area_right -= trap
        cand += h
    end
    (f(cand - h) + f(cand)) * h / 2 >= area_left - area_right ? cand : cand - h
end

_trapz(dx, y) = (2sum(y) - first(y) - last(y)) * dx / 2

function _trapz(f, a, b, N)
    (b - a) / N * (sum(f(xi) for xi in LinRange(a, b, N + 1)) + (f(a) + f(b)) / 2)
end
