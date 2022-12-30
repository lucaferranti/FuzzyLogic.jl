
"""
Parse julia code into a [`FuzzyInferenceSystem`](@ref).

### Example

```jldoctest
fis = @fis function tipper(service in 0:10, food in 0:10)::{tip in 0:30}
    poor = GaussianMF(1.5, 0.0)
    good = GaussianMF(1.5, 5.0)
    excellent = GaussianMF(1.5, 10.0)

    rancid = TrapezoidalMF(-2, 0, 1, 3)
    delicious = TrapezoidalMF(7, 9, 10, 12)

    cheap = TriangularMF(0, 5, 10)
    average = TriangularMF(10, 15, 20)
    generous = TriangularMF(20, 25, 30)

    and = ProdAnd
    or = ProbSumOr
    implication = ProdImplication

    service == poor || food == rancid => tip == cheap
    service == good => tip == average
    service == excellent || food == delicious => tip == generous

    aggregator = ProbSumAggregator
    defuzzifier = BisectorDefuzzifier
end

# output

tipper

Inputs:
-------
service ∈ [0, 10]
food ∈ [0, 10]

Outputs:
--------
tip ∈ [0, 30]

Membership functions
--------------------
poor = GaussianMF{Float64}(1.5, 0.0)
good = GaussianMF{Float64}(1.5, 5.0)
excellent = GaussianMF{Float64}(1.5, 10.0)
rancid = TrapezoidalMF{Int64}(-2, 0, 1, 3)
delicious = TrapezoidalMF{Int64}(7, 9, 10, 12)
cheap = TriangularMF{Int64}(0, 5, 10)
average = TriangularMF{Int64}(10, 15, 20)
generous = TriangularMF{Int64}(20, 25, 30)

Inference rules:
----------------
(service is poor ∨ food is rancid) => tip is cheap
service is good => tip is average
(service is excellent ∨ food is delicious) => tip is generous

Settings:
---------
FuzzyLogic.ProdAnd()

FuzzyLogic.ProbSumOr()

FuzzyLogic.ProdImplication()

FuzzyLogic.ProbSumAggregator()

FuzzyLogic.BisectorDefuzzifier()
```
"""
macro fis(ex::Expr)
    return _fis(ex)
end

const fis_settings = (:and, :or, :implication, :aggregator, :defuzzifier)

function _fis(ex::Expr)
    @capture ex function name_(argsin__)::{argsout__}
        body_
    end
    inputs = parse_variables(argsin)
    outputs = parse_variables(argsout)
    kwargs = parse_body(body)

    fis = :(FuzzyInferenceSystem(; name = $(QuoteNode(name)), inputs = $inputs,
                                 outputs = $outputs))
    append!(fis.args[2].args, kwargs)
    return fis
end

function parse_variables(args)
    map(args) do arg
        @capture(arg, varname_ in low_:high_) ||
            throw(ArgumentError("Invalid input $arg"))
        varname => Domain(low, high)
    end |> dictionary
end

function parse_body(body)
    mfnames = Symbol[]
    mfs = Expr(:vect)
    kwargs = Expr[]
    rules = Expr(:vect)
    for line in body.args
        line isa LineNumberNode && continue
        if @capture(line, var_=value_)
            if var in fis_settings # algorithm setting
                push!(kwargs, Expr(:kw, var, value isa Symbol ? :($value()) : value))
            else # membership function definition
                push!(mfnames, var)
                push!(mfs.args, value)
            end
        elseif @capture(line, ant_=>(cons__,) | cons__)
            push!(rules.args, parse_rule(ant, cons))
        end
    end
    isempty(mfnames) || push!(kwargs, Expr(:kw, :mfs, :(Dictionary($mfnames, $mfs))))
    isempty(rules.args) || push!(kwargs, Expr(:kw, :rules, rules))
    kwargs
end

function parse_rule(ant, cons)
    Expr(:call, :FuzzyRule, parse_antecedent(ant), parse_consequents(cons))
end

function parse_antecedent(ant)
    if @capture(ant, left_&&right_)
        return Expr(:call, :FuzzyAnd, parse_antecedent(left), parse_antecedent(right))
    elseif @capture(ant, left_||right_)
        return Expr(:call, :FuzzyOr, parse_antecedent(left), parse_antecedent(right))
    elseif @capture(ant, subj_==prop_)
        return Expr(:call, :FuzzyRelation, QuoteNode(subj), QuoteNode(prop))
    else
        throw(ArgumentError("Invalid premise $ant"))
    end
end

function parse_consequents(cons)
    newcons = map(cons) do c
        @capture(c, subj_==prop_) || throw(ArgumentError("Invalid consequence $c"))
        Expr(:call, :FuzzyRelation, QuoteNode(subj), QuoteNode(prop))
    end
    return Expr(:vect, newcons...)
end
