# Fuzzy Inference System

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

"""
Enlarges the domain `d` by a factor `p`. If `p` is negative, the interval is shrunk.
"""
function enlarge(d::Domain, p::Real)
    w = (high(d) - low(d)) * p
    return Domain(low(d) - w, high(d) + p)
end

const MF_TABLE = Dictionary{Symbol, AbstractMembershipFunction}

"""
Data structure representing a fuzzy inference system.
"""
Base.@kwdef struct FuzzyInferenceSystem{And <: AbstractAnd, Or <: AbstractOr,
                                        Impl <: AbstractImplication,
                                        Aggr <: AbstractAggregator,
                                        Defuzz <: AbstractDefuzzifier}
    name::Symbol
    inputs::Dictionary{Symbol, <:Domain} = Dictionary{Symbol, Domain}()
    outputs::Dictionary{Symbol, <:Domain} = Dictionary{Symbol, Domain}()
    mfs::Dictionary{Symbol, <:AbstractMembershipFunction} = Dictionary{Symbol,
                                                                       AbstractMembershipFunction
                                                                       }()
    and::And = DEFAULT_AND
    or::Or = DEFAULT_OR
    implication::Impl = DEFAULT_IMPLICATION
    aggregator::Aggr = DEFAULT_AGGREGATOR
    defuzzifier::Defuzz = DEFAULT_DEFUZZIFIER
end

function Base.show(io::IO, fis::FuzzyInferenceSystem)
    print(io, fis.name, "\n")
    if !isempty(fis.inputs)
        print(io, "\nINPUTS:\n-------\n")
        for (name, dom) in pairs(fis.inputs)
            println(io, name, " ∈ ", dom)
        end
    end

    if !isempty(fis.outputs)
        print(io, "\nOUTPUTS:\n--------\n")
        for (name, dom) in pairs(fis.outputs)
            println(io, name, " ∈ ", dom)
        end
    end

    if !isempty(fis.mfs)
        print(io, "\nMembership functions:\n$(repeat('-', 21))\n")
        for (name, mf) in pairs(fis.mfs)
            println(io, name, " = ", mf)
        end
    end

    println(io, "\n", fis.and)
    println(io, "\n", fis.or)
    println(io, "\n", fis.implication)
    println(io, "\n", fis.aggregator)
    println(io, "\n", fis.defuzzifier)
end

function (fis::FuzzyInferenceSystem)(; inputs...)
    # validate input
    for (name, val) in inputs
        @assert val in fis.inputs[name], "$name = $val not in domain $(fis.inputs[name])"
    end
    return fis
end
