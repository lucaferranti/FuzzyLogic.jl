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

struct Variable
    domain::Domain
    mfs::Dictionary{Symbol, AbstractPredicate}
end
Base.:(==)(x::Variable, y::Variable) = x.domain == y.domain && x.mfs == y.mfs
domain(var::Variable) = var.domain
memberships(var::Variable) = var.mfs
