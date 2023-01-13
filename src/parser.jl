using MacroTools

"""
    $(TYPEDSIGNATURES)

Parse julia code into a [`FuzzyInferenceSystem`](@ref).

# Extended help

### Example
```jldoctest
fis = @fis function tipper(service, food)::tip
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
service ∈ [0, 10] with membership function
    poor = GaussianMF{Float64}(0.0, 1.5)
    good = GaussianMF{Float64}(5.0, 1.5)
    excellent = GaussianMF{Float64}(10.0, 1.5)

food ∈ [0, 10] with membership function
    rancid = TrapezoidalMF{Int64}(-2, 0, 1, 3)
    delicious = TrapezoidalMF{Int64}(7, 9, 10, 12)


Outputs:
--------
tip ∈ [0, 30] with membership function
    cheap = TriangularMF{Int64}(0, 5, 10)
    average = TriangularMF{Int64}(10, 15, 20)
    generous = TriangularMF{Int64}(20, 25, 30)


Settings:
---------
ProdAnd()

ProbSumOr()

ProdImplication()

ProbSumAggregator()

BisectorDefuzzifier(100)
```
"""
macro fis(ex::Expr)
    return _fis(ex)
end

const fis_settings = (:and, :or, :implication, :aggregator, :defuzzifier)

function _fis(ex::Expr)
    @capture ex function name_(argsin__)::({argsout__} | argsout__)
        body_
    end
    inputs, outputs, opts, rules = parse_body(body, argsin, argsout)

    fis = :(FuzzyInferenceSystem(; name = $(QuoteNode(name)), inputs = $inputs,
                                 outputs = $outputs, rules = $rules))
    append!(fis.args[2].args, opts)
    return fis
end

function parse_variable(var, args)
    mfs = :(dictionary([]))
    ex = :(Variable())
    for arg in args
        if @capture(arg, domain=low_:high_)
            push!(ex.args, :(Domain($low, $high)))
        elseif @capture(arg, mfname_=mfex_)
            push!(mfs.args[2].args, :($(QuoteNode(mfname)) => $mfex))
        else
            throw(ArgumentError("Invalid expression $arg"))
        end
    end
    push!(ex.args, mfs)
    return :($(QuoteNode(var)) => $ex)
end

function parse_body(body, argsin, argsout)
    opts = Expr[]
    rules = :(FuzzyRule[])
    inputs = :(dictionary([]))
    outputs = :(dictionary([]))
    for line in body.args
        line isa LineNumberNode && continue
        if @capture(line, var_:=begin args__ end)
            if var in argsin
                push!(inputs.args[2].args, parse_variable(var, args))
            elseif var in argsout
                push!(outputs.args[2].args, parse_variable(var, args))
            else
                throw(ArgumentError("Undefined variable $var"))
            end
        elseif @capture(line, var_=value_)
            var in fis_settings ||
                throw(ArgumentError("Invalid keyword $var in line $line"))
            push!(opts, Expr(:kw, var, value isa Symbol ? :($value()) : value))
        elseif @capture(line, ant_-->(cons__,) | cons__)
            push!(rules.args, parse_rule(ant, cons))
        end
    end
    return inputs, outputs, opts, rules
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
