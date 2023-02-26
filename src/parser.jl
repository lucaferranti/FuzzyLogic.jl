using MacroTools

"""
    $(TYPEDSIGNATURES)

Parse julia code into a [`MamdaniFuzzySystem`](@ref). See extended help for an example.

# Extended help

### Example
```jldoctest
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

    and = ProdAnd
    or = ProbSumOr
    implication = ProdImplication

    service == poor || food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous

    aggregator = ProbSumAggregator
    defuzzifier = BisectorDefuzzifier
end

# output

tipper

Inputs:
-------
service ∈ [0, 10] with membership functions:
    poor = GaussianMF{Float64}(0.0, 1.5)
    good = GaussianMF{Float64}(5.0, 1.5)
    excellent = GaussianMF{Float64}(10.0, 1.5)

food ∈ [0, 10] with membership functions:
    rancid = TrapezoidalMF{Int64}(-2, 0, 1, 3)
    delicious = TrapezoidalMF{Int64}(7, 9, 10, 12)


Outputs:
--------
tip ∈ [0, 30] with membership functions:
    cheap = TriangularMF{Int64}(0, 5, 10)
    average = TriangularMF{Int64}(10, 15, 20)
    generous = TriangularMF{Int64}(20, 25, 30)


Inference rules:
----------------
(service is poor ∨ food is rancid) --> tip is cheap
service is good --> tip is average
(service is excellent ∨ food is delicious) --> tip is generous


Settings:
---------
- ProdAnd()
- ProbSumOr()
- ProdImplication()
- ProbSumAggregator()
- BisectorDefuzzifier(100)
```
"""
macro mamfis(ex::Expr)
    return _fis(ex, :MamdaniFuzzySystem)
end

"""
    $(TYPEDSIGNATURES)

Parse julia code into a [`SugenoFuzzySystem`](@ref). See extended help for an example.

# Extended help

### Example
```jldoctest
fis = @sugfis function tipper(service, food)::tip
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
        cheap = 0
        average = food
        generous = 2service, food, -2
    end

    service == poor && food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous
end

# output

tipper

Inputs:
-------
service ∈ [0, 10] with membership functions:
    poor = GaussianMF{Float64}(0.0, 1.5)
    good = GaussianMF{Float64}(5.0, 1.5)
    excellent = GaussianMF{Float64}(10.0, 1.5)

food ∈ [0, 10] with membership functions:
    rancid = TrapezoidalMF{Int64}(-2, 0, 1, 3)
    delicious = TrapezoidalMF{Int64}(7, 9, 10, 12)


Outputs:
--------
tip ∈ [0, 30] with membership functions:
    cheap = 0
    average = food
    generous = 2service + food - 2


Inference rules:
----------------
(service is poor ∧ food is rancid) --> tip is cheap
service is good --> tip is average
(service is excellent ∨ food is delicious) --> tip is generous


Settings:
---------
- ProdAnd()
- ProbSumOr()
```
"""
macro sugfis(ex::Expr)
    return _fis(ex, :SugenoFuzzySystem)
end

function _fis(ex::Expr, type)
    @capture ex function name_(argsin__)::({argsout__} | argsout__)
        body_
    end
    argsin, argsout = process_args(argsin), process_args(argsout)
    inputs, outputs, opts, rules = parse_body(body, argsin, argsout, type)

    fis = :($type(; name = $(QuoteNode(name)), inputs = $inputs,
                  outputs = $outputs, rules = $rules))
    append!(fis.args[2].args, opts)
    return fis
end

process_args(x::Symbol) = [x]
function process_args(ex::Expr)
    if @capture(ex, x_[start_:stop_])
        [Symbol(x, i) for i in start:stop]
    else
        throw(ArgumentError("invalid expression $ex"))
    end
end
process_args(v::Vector) = mapreduce(process_args, vcat, v)

"""
convert a symbol or expression to variable name. A symbol is returned as such.
An expression in the form `:(x[i])` is converted to a symbol `:xi`.
"""
to_var_name(ex::Symbol) = ex
function to_var_name(ex::Expr)
    if @capture(ex, x_[i_])
        return Symbol(x, i)
    else
        throw(ArgumentError("Invalid variable name $ex"))
    end
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

function parse_body(body, argsin, argsout, type)
    opts = Expr[]
    rules = Expr(:vect)
    inputs = :(dictionary([]))
    outputs = :(dictionary([]))
    for line in body.args
        line isa LineNumberNode && continue
        if @capture(line, var_:=begin args__ end)
            var = to_var_name(var)
            if var in argsin
                push!(inputs.args[2].args, parse_variable(var, args))
            elseif var in argsout
                # TODO: makes this more scalable
                push!(outputs.args[2].args,
                      type == :SugenoFuzzySystem ? parse_sugeno_output(var, args, argsin) :
                      parse_variable(var, args))
            else
                throw(ArgumentError("Undefined variable $var"))
            end
        elseif @capture(line, var_=value_)
            var in SETTINGS[type] ||
                throw(ArgumentError("Invalid keyword $var in line $line"))
            push!(opts, Expr(:kw, var, value isa Symbol ? :($value()) : value))
        elseif @capture(line, ant_-->(cons__,) * w_Number)
            push!(rules.args, parse_rule(ant, cons, w))
        elseif @capture(line, ant_-->p_ == q_ * w_Number)
            push!(rules.args, parse_rule(ant, [:($p == $q)], w))
        elseif @capture(line, ant_-->(cons__,) | cons__)
            push!(rules.args, parse_rule(ant, cons))
        else
            throw(ArgumentError("Invalid expression $line"))
        end
    end
    return inputs, outputs, opts, rules
end

#################
# RULES PARSING #
#################

function parse_rule(ant, cons, w)
    Expr(:call, :WeightedFuzzyRule, parse_antecedent(ant), parse_consequents(cons), w)
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
        return Expr(:call, :FuzzyRelation, QuoteNode(to_var_name(subj)),
                    QuoteNode(to_var_name(prop)))
    elseif @capture(ant, subj_!=prop_)
        return Expr(:call, :FuzzyNegation, QuoteNode(to_var_name(subj)),
                    QuoteNode(to_var_name(prop)))
    else
        throw(ArgumentError("Invalid premise $ant"))
    end
end

function parse_consequents(cons)
    newcons = map(cons) do c
        @capture(c, subj_==prop_) || throw(ArgumentError("Invalid consequence $c"))
        Expr(:call, :FuzzyRelation, QuoteNode(to_var_name(subj)),
             QuoteNode(to_var_name(prop)))
    end
    return Expr(:vect, newcons...)
end

############################
# PARSE SUGENO EXPRESSIONS #
############################

function parse_sugeno_coeffs(exs::Vector, argsin::Vector, mfname::Symbol)
    coeffs = :([$([0 for _ in 1:length(argsin)]...)])
    offsets = []
    for ex in exs
        if @capture(ex, c_Number*var_Symbol)
            idx = findfirst(==(var), argsin)
            isnothing(idx) &&
                throw(ArgumentError("Unkonwn variable $var in $mfname definition"))
            coeffs.args[idx] = c
        elseif ex isa Number
            push!(offsets, ex)
        elseif ex isa Symbol
            idx = findfirst(==(ex), argsin)
            isnothing(idx) &&
                throw(ArgumentError("Unkonwn variable $ex in $mfname definition"))
            coeffs.args[idx] = 1
        else
            throw(ArgumentError("Invalid expression $ex in $mfname definition"))
        end
    end
    length(offsets) < 2 ||
        throw(ArgumentError("multiple constants in $(Expr(:tuple, exs...))"))
    coeffs, isempty(offsets) ? 0 : only(offsets)
end

function parse_sugeno_output(var, args, argsin)
    mfs = :(dictionary([]))
    ex = :(Variable())
    inputs = Expr(:vect, map(QuoteNode, argsin)...)
    for arg in args
        if @capture(arg, domain=low_:high_)
            push!(ex.args, :(Domain($low, $high)))
        elseif @capture(arg, mfname_=c_Number)
            push!(mfs.args[2].args, :($(QuoteNode(mfname)) => $(ConstantSugenoOutput(c))))
        elseif @capture(arg, mfname_=(mfex__,) | mfex__)
            coeffs, offset = parse_sugeno_coeffs(mfex, argsin, mfname)
            mf = :(LinearSugenoOutput(Dictionary($inputs, $coeffs), $offset))
            push!(mfs.args[2].args, :($(QuoteNode(mfname)) => $mf))
        else
            throw(ArgumentError("Invalid expression $arg"))
        end
    end
    push!(ex.args, mfs)
    return :($(QuoteNode(var)) => $ex)
end
