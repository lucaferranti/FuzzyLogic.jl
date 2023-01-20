# Fuzzy Inference System

abstract type AbstractFuzzySystem end

"""
Data structure representing a type-1 Mamdani fuzzy inference system.
It can be created using the [`@mamfis`](@ref) macro.
It can be called as a function to evaluate the system at a given input.
The inputs should be given as keyword arguments.

# Extended help

### Example

```jldoctest; filter=r"Dictionaries\\."
fis = @mamfis function tipper(service, food)::tip
    service := begin
      domain = 0:10
      poor = GaussianMF(0.0, 1.5)
      good = GaussianMF(5.0, 1.5)
      excellent = GaussianMF(10.0, 1.5)
    end

    food := begin
      domain = 0:10
      rancid = TrapezoidalMF(-2, 0, 1, 3)
      delicious = TrapezoidalMF(7, 9, 10, 12)
    end

    tip := begin
      domain = 0:30
      cheap = TriangularMF(0, 5, 10)
      average = TriangularMF(10, 15, 20)
      generous = TriangularMF(20, 25, 30)
    end

    service == poor || food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous
end

fis(service=1, food=2)

# output

1-element Dictionaries.Dictionary{Symbol, Float64}
 :tip │ 5.558585929783786
```
"""
Base.@kwdef struct MamdaniFuzzySystem{And <: AbstractAnd, Or <: AbstractOr,
                                      Impl <: AbstractImplication,
                                      Aggr <: AbstractAggregator,
                                      Defuzz <: AbstractDefuzzifier} <:
                   AbstractFuzzySystem
    "name of the system."
    name::Symbol
    "input variables and corresponding domain."
    inputs::Dictionary{Symbol, Variable} = Dictionary{Symbol, Variable}()
    "output variables and corresponding domain."
    outputs::Dictionary{Symbol, Variable} = Dictionary{Symbol, Variable}()
    "inference rules."
    rules::Vector{FuzzyRule} = FuzzyRule[]
    "method used to compute conjuction in rules, default [`MinAnd`](@ref)."
    and::And = MinAnd()
    "method used to compute disjunction in rules, default [`MaxOr`](@ref)."
    or::Or = MaxOr()
    "method used to compute implication in rules, default [`MinImplication`](@ref)"
    implication::Impl = MinImplication()
    "method used to aggregate fuzzy outputs, default [`MaxAggregator`](@ref)."
    aggregator::Aggr = MaxAggregator()
    "method used to defuzzify the result, default [`CentroidDefuzzifier`](@ref)."
    defuzzifier::Defuzz = CentroidDefuzzifier()
end

implication(fis::MamdaniFuzzySystem) = fis.implication

print_title(io::IO, s::String) = println(io, "\n$s\n", repeat('-', length(s)))

function Base.show(io::IO, fis::AbstractFuzzySystem)
    print(io, fis.name, "\n")
    if !isempty(fis.inputs)
        print_title(io, "Inputs:")
        for (name, var) in pairs(fis.inputs)
            println(io, name, " ∈ ", domain(var), " with membership functions:")
            for (name, mf) in pairs(memberships(var))
                println(io, "    ", name, " = ", mf)
            end
            println(io)
        end
    end

    if !isempty(fis.outputs)
        print_title(io, "Outputs:")
        for (name, var) in pairs(fis.outputs)
            println(io, name, " ∈ ", domain(var), " with membership functions:")
            for (name, mf) in pairs(memberships(var))
                println(io, "    ", name, " = ", mf)
            end
            println(io)
        end
    end

    if !isempty(fis.rules)
        print_title(io, "Inference rules:")
        for rule in fis.rules
            println(io, rule)
        end
        println(io)
    end
    settings = setdiff(fieldnames(typeof(fis)), (:name, :inputs, :outputs, :rules))
    if !isempty(settings)
        print_title(io, "Settings:")
        for setting in settings
            println(io, "- ", getproperty(fis, setting))
        end
    end
end

"""
Data structure representing a type-1 Sugeno fuzzy inference system.
It can be created using the [`@sugfis`](@ref) macro.
It can be called as a function to evaluate the system at a given input.
The inputs should be given as keyword arguments.

$(TYPEDFIELDS)
"""
Base.@kwdef struct SugenoFuzzySystem{And <: AbstractAnd, Or <: AbstractOr} <:
                   AbstractFuzzySystem
    "name of the system."
    name::Symbol
    "input variables and corresponding domain."
    inputs::Dictionary{Symbol, Variable} = Dictionary{Symbol, Variable}()
    "output variables and corresponding domain."
    outputs::Dictionary{Symbol, Variable} = Dictionary{Symbol, Variable}()
    "inference rules."
    rules::Vector{FuzzyRule} = FuzzyRule[]
    "method used to compute conjuction in rules, default [`MinAnd`](@ref)."
    and::And = ProdAnd()
    "method used to compute disjunction in rules, default [`MaxOr`](@ref)."
    or::Or = ProbSumOr()
end

const SETTINGS = (MamdaniFuzzySystem = (:and, :or, :implication, :aggregator,
                                        :defuzzifier),
                  SugenoFuzzySystem = (:and, :or))

implication(::SugenoFuzzySystem) = ProdImplication()
