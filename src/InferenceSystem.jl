# Fuzzy Inference System

"""
Data structure representing a type-1 Mamdami fuzzy inference system.
A Fuzzy inference system can be created using [`@fis`](@ref) macro.
After that it can be called as a function to evaluate the system at a given input.
The inputs should be given as keyword arguments.

# Extended help

### Example

```jldoctest
fis = @fis function tipper(service in 0:10, food in 0:10)::{tip in 0:30}
    poor = GaussianMF(0.0, 1.5)
    good = GaussianMF(5.0, 1.5)
    excellent = GaussianMF(10.0, 1.5)

    rancid = TrapezoidalMF(-2, 0, 1, 3)
    delicious = TrapezoidalMF(7, 9, 10, 12)

    cheap = TriangularMF(0, 5, 10)
    average = TriangularMF(10, 15, 20)
    generous = TriangularMF(20, 25, 30)

    service == poor || food == rancid => tip == cheap
    service == good => tip == average
    service == excellent || food == delicious => tip == generous
end

fis(; service=1, food=2)

# output

1-element Dictionaries.Dictionary{Symbol, Any}
 :tip │ 5.558585929783786
```
"""
Base.@kwdef struct FuzzyInferenceSystem{And <: AbstractAnd, Or <: AbstractOr,
                                        Impl <: AbstractImplication,
                                        Aggr <: AbstractAggregator,
                                        Defuzz <: AbstractDefuzzifier}
    "name of the system."
    name::Symbol
    "input variables and corresponding domain."
    inputs::Dictionary{Symbol, <:Domain} = Dictionary{Symbol, Domain}()
    "output variables and corresponding domain."
    outputs::Dictionary{Symbol, <:Domain} = Dictionary{Symbol, Domain}()
    "membership functions."
    mfs::Dictionary{Symbol, <:AbstractMembershipFunction} = Dictionary{Symbol,
                                                                       AbstractMembershipFunction
                                                                       }()
    "inference rules."
    rules::Vector{FuzzyRule} = FuzzyRule[]
    "method used to compute conjuction in rules, default [`MinAnd`](@ref)."
    and::And = DEFAULT_AND
    "method used to compute disjunction in rules, default [`MaxOr`](@ref)."
    or::Or = DEFAULT_OR
    "method used to compute implication in rules, default [`MinImplication`](@ref)"
    implication::Impl = DEFAULT_IMPLICATION
    "method used to aggregate fuzzy outputs, default [`MaxAggregator`](@ref)."
    aggregator::Aggr = DEFAULT_AGGREGATOR
    "method used to defuzzify the result, default [`CentroidDefuzzifier`](@ref)."
    defuzzifier::Defuzz = DEFAULT_DEFUZZIFIER
end

print_title(io::IO, s::String) = println(io, "\n$s\n", repeat('-', length(s)))

function Base.show(io::IO, fis::FuzzyInferenceSystem)
    print(io, fis.name, "\n")
    if !isempty(fis.inputs)
        print_title(io, "Inputs:")
        for (name, dom) in pairs(fis.inputs)
            println(io, name, " ∈ ", dom)
        end
    end

    if !isempty(fis.outputs)
        print_title(io, "Outputs:")
        for (name, dom) in pairs(fis.outputs)
            println(io, name, " ∈ ", dom)
        end
    end

    if !isempty(fis.mfs)
        print_title(io, "Membership functions")
        for (name, mf) in pairs(fis.mfs)
            println(io, name, " = ", mf)
        end
    end

    if !isempty(fis.rules)
        print_title(io, "Inference rules:")
        for rule in fis.rules
            println(io, rule)
        end
    end
    print_title(io, "Settings:")
    println(io, fis.and)
    println(io, "\n", fis.or)
    println(io, "\n", fis.implication)
    println(io, "\n", fis.aggregator)
    println(io, "\n", fis.defuzzifier)
end
