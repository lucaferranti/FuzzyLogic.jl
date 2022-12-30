# Fuzzy inference system options

## T-Norms

abstract type AbstractAnd end

struct MinAnd <: AbstractAnd end
(ma::MinAnd)(x, y) = min(x, y)

struct ProdAnd <: AbstractAnd end
(pa::ProdAnd)(x, y) = x * y

## S-Norms

abstract type AbstractOr end

struct MaxOr <: AbstractOr end
(mo::MaxOr)(x, y) = max(x, y)

struct ProbSumOr <: AbstractOr end
(pso::ProbSumOr)(x, y) = x + y - x * y

## Implication

abstract type AbstractImplication end

struct MinImplication <: AbstractImplication end
(mini::MinImplication)(x, y) = min(x, y)

struct ProdImplication <: AbstractImplication end
(pim::ProdImplication)(x, y) = x * y

## Aggregation

abstract type AbstractAggregator end

struct MaxAggregator <: AbstractAggregator end
(ma::MaxAggregator)(x, y) = max(x, y)

struct ProbSumAggregator <: AbstractAggregator end
(psa::ProbSumAggregator)(x, y) = x + y - x * y

## Defuzzification

abstract type AbstractDefuzzifier end

Base.@kwdef struct CentroidDefuzzifier <: AbstractDefuzzifier
    "step size for integration"
    h::Float64 = 1e-3
end

function (cd::CentroidDefuzzifier)(f::Function, dom::Domain)
    _trapz(x -> x * f(x), low(dom), high(dom), cd.h) / _trapz(f, low(dom), high(dom), cd.h)
end

struct BisectorDefuzzifier <: AbstractDefuzzifier end
function (cd::BisectorDefuzzifier)(f::Function, dom::Domain)
    _trapz(x -> x * f(x), low(dom), high(dom), 0.001) /
    _trapz(f, low(dom), high(dom), 0.001)
end

function _trapz(f, a, b, h)
    h / 2 * (sum(2f(xi) for xi in a:h:b) - f(a) - f(b))
end

## Defaults

const DEFAULT_AND = MinAnd()
const DEFAULT_OR = MaxOr()
const DEFAULT_IMPLICATION = MinImplication()
const DEFAULT_AGGREGATOR = MaxAggregator()
const DEFAULT_DEFUZZIFIER = CentroidDefuzzifier()
