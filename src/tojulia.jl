
"""
Compile the fuzzy inference system into stand-alone Julia code.
If the first argument is a string, it write the code in the given file, otherwise it returns
the Julia expression of the code.

### Inputs

- `fname::AbstractString` -- file where to write
- `fis::AbstractFuzzySystem` -- fuzzy system to compile
- `name::Symbol` -- name of the generated function, default `fis.name`

### Notes

Only type-1 inference systems are supported
"""
function compilefis(fname::AbstractString, fis::AbstractFuzzySystem,
                    name::Symbol = fis.name)
    open(fname, "w") do io
        write(io, string(to_expr(fis, name)))
    end
end

@inline compilefis(fis::AbstractFuzzySystem, name::Symbol = fis.name) = to_expr(fis, name)

function to_expr(fis::MamdaniFuzzySystem, name::Symbol = fis.name)
    body = quote end
    for (varname, var) in pairs(fis.inputs)
        for (mfname, mf) in pairs(var.mfs)
            push!(body.args, :($mfname = $(to_expr(mf, varname))))
        end
    end

    # parse rules. Antecedents are stored in local variables, which can be useful if one has
    # multiple outputs. Each rule is converted to a dictionary indexed by output variable.
    rules = Vector{Dict{Symbol, Expr}}(undef, length(fis.rules))
    for (i, rule) in enumerate(fis.rules)
        ant_name = Symbol(:ant, i)
        ant_body = to_expr(fis, rule.antecedent)
        push!(body.args, :($ant_name = $ant_body))
        rules[i] = to_expr(fis, rule; antidx = i)
    end

    # construct expression that computes each output
    for (varname, var) in pairs(fis.outputs)
        varagg = Symbol(varname, :_agg)
        out_dom = LinRange(low(var.domain), high(var.domain), fis.defuzzifier.N + 1)
        push!(body.args, :($varagg = collect($out_dom))) # vector for aggregated output

        # evaluate output membership functions.
        rule_eval = quote end
        for (mfname, mf) in pairs(var.mfs)
            push!(rule_eval.args, :($mfname = $(to_expr(mf))))
        end

        # construct expression that performs implication and aggregation of all rules
        agg = :()
        for rule in rules
            if haskey(rule, varname)
                if agg == :()
                    agg = rule[varname]
                else
                    agg = to_expr(fis.aggregator, agg, rule[varname])
                end
            end
        end

        defuzz = to_expr(fis.defuzzifier, Symbol(varname, :_agg), var.domain) # defuzzifier

        ex = quote
            @inbounds for (i, x) in enumerate($varagg)
                $rule_eval
                $varagg[i] = $agg
            end
            $varname = $defuzz
        end

        push!(body.args, ex)
    end

    prettify(:(function $name($(collect(keys(fis.inputs))...))
                   $body
                   return $(keys(fis.outputs)...)
               end))
end

function to_expr(fis::SugenoFuzzySystem, name::Symbol = fis.name)
    body = quote end
    for (varname, var) in pairs(fis.inputs)
        for (mfname, mf) in pairs(var.mfs)
            push!(body.args, :($mfname = $(to_expr(mf, varname))))
        end
    end

    rules = Vector{Dict{Symbol, Expr}}(undef, length(fis.rules))
    tot_weight = Expr(:call, :+)
    for (i, rule) in enumerate(fis.rules)
        ant, res = to_expr(fis, rule, i)
        push!(body.args, ant)
        push!(tot_weight.args, Symbol(:ant, i))
        rules[i] = res
    end
    push!(body.args, :(tot_weight = $tot_weight))

    for (varname, var) in pairs(fis.outputs)
        num = Expr(:call, :+)
        for (mfname, mf) in pairs(var.mfs)
            push!(body.args, :($mfname = $(to_expr(mf))))
        end
        for rule in rules
            if haskey(rule, varname)
                push!(num.args, rule[varname])
            end
        end
        ex = :($varname = $num / tot_weight)
        push!(body.args, ex)
    end

    prettify(:(function $name($(collect(keys(fis.inputs))...))
                   $body
                   return $(keys(fis.outputs)...)
               end))
end

########################################
# MEMBERSHIP FUNCTIONS CODE GENERATION #
########################################

to_expr(mf::GaussianMF, x = :x) = :(exp(-($x - $(mf.mu))^2 / $(2 * mf.sig^2)))
function to_expr(mf::TriangularMF, x = :x)
    :(max(min(($x - $(mf.a)) / $(mf.b - mf.a), ($(mf.c) - $x) / $(mf.c - mf.b)), 0))
end

function to_expr(mf::TrapezoidalMF, x = :x)
    :(max(min(($x - $(mf.a)) / $(mf.b - mf.a), 1, ($(mf.d) - $x) / $(mf.d - mf.c)), 0))
end

function to_expr(mf::LinearMF, x = :x)
    :(max(min(($x - $(mf.a)) / ($(mf.b) - $(mf.a)), 1), 0))
end

function to_expr(mf::SigmoidMF, x = :x)
    :(1 / (1 + exp(-$(mf.a) * ($x - $(mf.c)))))
end

function to_expr(mf::DifferenceSigmoidMF, x = :x)
    :(max(min(1 / (1 + exp(-$(mf.a1) * ($x - $(mf.c1)))) -
              1 / (1 + exp(-$(mf.a2) * ($x - $(mf.c2)))), 1), 0))
end

function to_expr(mf::ProductSigmoidMF, x = :x)
    :(1 / ((1 + exp(-$(mf.a1) * ($x - $(mf.c1)))) * (1 + exp(-$(mf.a2) * ($x - $(mf.c2))))))
end

function to_expr(mf::GeneralizedBellMF, x = :x)
    :(1 / (1 + abs(($x - $(mf.c)) / $(mf.a))^$(2mf.b)))
end

function to_expr(s::SShapeMF, x = :x)
    :(if $x <= $(s.a)
          zero(float($(typeof(x))))
      elseif $x >= $(s.b)
          one(float(typeof($x)))
      elseif $x >= $((s.a + s.b) / 2)
          1 - $(2 / (s.b - s.a)^2) * ($x - $(s.b))^2
      else
          $(2 / (s.b - s.a)^2) * ($x - $(s.a))^2
      end)
end

function to_expr(mf::ZShapeMF, x = :x)
    :(if $x <= $(mf.a)
          one(float($(typeof(x))))
      elseif $x >= $(mf.b)
          zero(float(typeof($x)))
      elseif $x >= $((mf.a + mf.b) / 2)
          $(2 / (mf.b - mf.a)^2) * ($x - $(mf.b))^2
      else
          1 - $(2 / (mf.b - mf.a)^2) * ($x - $(mf.a))^2
      end)
end

function to_expr(p::PiShapeMF, x = :x)
    :(if $x <= $(p.a) || $x >= $(p.d)
          zero(float(typeof($x)))
      elseif $(p.b) <= $x <= $(p.c)
          one(float(typeof($x)))
      elseif $x <= $((p.a + p.b) / 2)
          $(2 / (p.b - p.a)^2) * ($x - $(p.a))^2
      elseif $x <= $(p.b)
          1 - $(2 / (p.b - p.a)^2) * ($x - $(p.b))^2
      elseif $x <= $((p.c + p.d) / 2)
          1 - $(2 / (p.d - p.c)^2) * ($x - $(p.c))^2
      else
          $(2 / (p.d - p.c)^2) * ($x - $(p.d))^2
      end)
end

function to_expr(plmf::PiecewiseLinearMF, x = :x)
    :(if $x <= $(plmf.points[1][1])
          $(float(plmf.points[1][2]))
      elseif $x >= $(plmf.points[end][1])
          $(float(plmf.points[end][2]))
      else
          pnts = $(plmf.points)
          idx = findlast(p -> $x >= p[1], pnts)
          x1, y1 = pnts[idx]
          x2, y2 = pnts[idx + 1]
          (y2 - y1) / (x2 - x1) * ($x - x1) + y1
      end)
end

function to_expr(mf::WeightedMF, x = :x)
    :($(mf.w) * $(to_expr(mf.mf, x)))
end

to_expr(mf::ConstantSugenoOutput) = mf.c

function to_expr(mf::LinearSugenoOutput)
    ex = Expr(:call, :+, mf.offset)
    for (varname, coeff) in pairs(mf.coeffs)
        push!(ex.args, :($coeff * $varname))
    end
    return ex
end

#####################################
# LOGICAL OPERATORS CODE GENERATION #
#####################################

to_expr(::MinAnd, x = :y, y = :y) = :(min($x, $y))
to_expr(::ProdAnd, x = :x, y = :y) = :($x * $y)
to_expr(::LukasiewiczAnd, x = :x, y = :y) = :(max(0, $x + $y - 1))
function to_expr(::DrasticAnd, x = :x, y = :y)
    :(isone($x) || isone($y) ? min($x, $y) : zero(promote_type(typeof($x), typeof($y))))
end

function to_expr(::NilpotentAnd, x = :x, y = :y)
    :($x + $y > 1 ? min($x, $y) : zero(promote_type(typeof($x), typeof($y))))
end
function to_expr(::HamacherAnd, x = :x, y = :y)
    :(let z = ($x * $y) / ($x + $y - $x * $y)
          isfinite(z) ? z : zero(z)
      end)
end
to_expr(::EinsteinAnd, x = :x, y = :y) = :(($x * $y) / (2 - $x - $y + $x * $y))

to_expr(::MaxOr, x = :x, y = :y) = :(max($x, $y))
to_expr(::ProbSumOr, x = :x, y = :y) = :($x + $y - $x * $y)
to_expr(::BoundedSumOr, x = :x, y = :y) = :(min(1, $x + $y))
function to_expr(::DrasticOr, x = :x, y = :y)
    :(iszero($x) || iszero($y) ? max($x, $y) : one(promote_type(typeof($x), typeof($y))))
end
function to_expr(::NilpotentOr, x = :x, y = :y)
    :($x + $y < 1 ? max($x, $y) : one(promote_type(typeof($x), typeof($y))))
end
function to_expr(::HamacherOr, x = :x, y = :y)
    :(let z = ($x + $y - 2 * $x * $y) / (1 - $x * $y)
          isfinite(z) ? z : one(z)
      end)
end
to_expr(::EinsteinOr, x = :x, y = :y) = :(($x + $y) / (1 + $x * $y))

to_expr(::MinImplication, x = :x, y = :y) = :(min($x, $y))
to_expr(::ProdImplication, x = :x, y = :y) = :($x * $y)

to_expr(::MaxAggregator, x = :x, y = :y) = :(max($x, $y))
to_expr(::ProbSumAggregator, x = :x, y = :y) = :($x + $y - $x * $y)

#########################
# RULES CODE GENERATION #
#########################

function to_expr(fis::MamdaniFuzzySystem, rule::FuzzyRule; antidx = nothing)
    res = Dict{Symbol, Expr}()
    for cons in rule.consequent
        ant = isnothing(antidx) ? to_expr(fis, rule.antecedent) : Symbol(:ant, antidx)
        res[cons.subj] = to_expr(fis.implication, ant, to_expr(fis, cons))
    end
    res
end

function to_expr(fis::MamdaniFuzzySystem, rule::WeightedFuzzyRule; antidx = nothing)
    res = to_expr(fis, FuzzyRule(rule.antecedent, rule.consequent); antidx)
    for (var, ex) in res
        res[var] = :($(rule.weight) * $ex)
    end
    res
end

to_expr(::AbstractFuzzySystem, r::FuzzyRelation) = r.prop
to_expr(::AbstractFuzzySystem, r::FuzzyNegation) = :(1 - $(r.prop))

function to_expr(fis::AbstractFuzzySystem, r::FuzzyAnd)
    to_expr(fis.and, to_expr(fis, r.left), to_expr(fis, r.right))
end

function to_expr(fis::AbstractFuzzySystem, r::FuzzyOr)
    to_expr(fis.or, to_expr(fis, r.left), to_expr(fis, r.right))
end

function to_expr(fis::SugenoFuzzySystem, rule::AbstractRule, antidx)
    antbody = to_expr(fis, rule.antecedent)
    if rule isa WeightedFuzzyRule
        antbody = :($(rule.weight) * $antbody)
    end
    antname = Symbol(:ant, antidx)
    ant = Expr(:(=), antname, antbody)
    res = Dict{Symbol, Expr}()
    for cons in rule.consequent
        res[cons.subj] = Expr(:call, :*, antname, to_expr(fis, cons))
    end
    return ant, res
end

################################
# DEFUZZIFIERS CODE GENERATION #
################################

function to_expr(defuzz::CentroidDefuzzifier, mf, dom::Domain)
    :((2sum(mfi * xi
            for (mfi, xi) in zip($mf, $(LinRange(low(dom), high(dom), defuzz.N + 1)))) -
       first($mf) * $(low(dom)) - last($mf) * $(high(dom))) /
      (2sum($mf) - first($mf) - last($mf)))
end

function to_expr(defuzz::BisectorDefuzzifier, mf, dom::Domain{T}) where {T <: Real}
    area_left = zero(T)
    h = (high(dom) - low(dom)) / defuzz.N
    area_right = :((2sum($mf) - first(mf) - last(mf)) * $(h / 2))
    cand = LinRange(low(dom), high(dom), defuzz.N + 1)
    :(let
          mf = $mf
          area_left = $area_left
          h = $h
          area_right = (2sum(mf) - first(mf) - last(mf)) * $(h / 2)
          cand = $cand
          i = firstindex(mf)
          while area_left < area_right
              trap = (mf[i] + mf[i + 1]) * $(h / 2)
              area_left += trap
              area_right -= trap
              i += 1
          end
          (mf[i - 1] + mf[i]) * $(h / 2) >= area_left - area_right ? cand[i] : cand[i - 1]
      end)
end

function to_expr(defuzz::LeftMaximumDefuzzifier, mf, dom::Domain{T}) where {T <: Real}
    :(let
          res = $(float(low(dom)))
          y = $mf
          maxval = first(y)
          for (xi, yi) in zip($(LinRange(low(dom), high(dom), defuzz.N + 1)), y)
              if yi > maxval + $(defuzz.tol)
                  res = xi
                  maxval = yi
              end
          end
          res
      end)
end

function to_expr(defuzz::RightMaximumDefuzzifier, mf, dom::Domain{T}) where {T <: Real}
    :(let
          res = $(float(low(dom)))
          y = $mf
          maxval = first(y)
          for (xi, yi) in zip($(LinRange(low(dom), high(dom), defuzz.N + 1)), y)
              if yi >= maxval - $(defuzz.tol)
                  res = xi
                  maxval = yi
              end
          end
          res
      end)
end

function to_expr(defuzz::MeanOfMaximaDefuzzifier, mf, dom::Domain{T}) where {T <: Real}
    :(let
          res = $(zero(float(T)))
          y = $mf
          maxval = first(y)
          maxcnt = 0
          for (xi, yi) in zip($(LinRange(low(dom), high(dom), defuzz.N + 1)), y)
              if yi - maxval > $(defuzz.tol) # reset mean calculation
                  res = xi
                  maxval = yi
                  maxcnt = 1
              elseif abs(yi - maxval) <= $(defuzz.tol)
                  res += xi
                  maxcnt += 1
              end
          end
          res / maxcnt
      end)
end
