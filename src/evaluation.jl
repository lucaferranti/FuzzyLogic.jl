# utilities to evaluate a fuzzy inference system

function (fr::FuzzyRelation)(fis::AbstractFuzzySystem,
                             inputs::T)::float(eltype(T)) where {T <: NamedTuple}
    memberships(fis.inputs[fr.subj])[fr.prop](inputs[fr.subj])
end

function (fa::FuzzyAnd)(fis::AbstractFuzzySystem, inputs)
    fis.and(fa.left(fis, inputs), fa.right(fis, inputs))
end

function (fo::FuzzyOr)(fis::AbstractFuzzySystem, inputs)
    fis.or(fo.left(fis, inputs), fo.right(fis, inputs))
end

function (fr::FuzzyRule)(fis::AbstractFuzzySystem, inputs)::Dictionary{Symbol, Function}
    map(fr.consequent) do c
        mf = memberships(fis.outputs[c.subj])[c.prop]
        c.subj => Base.Fix1(implication(fis), fr.antecedent(fis, inputs)) ∘ mf
    end |> dictionary
end

function (fis::MamdaniFuzzySystem)(inputs::T)::Dictionary{Symbol,
                                                          float(eltype(T))
                                                          } where {T <: NamedTuple}
    rules = [rule(fis, inputs) for rule in fis.rules]
    map(pairs(fis.outputs)) do (y, var)
        fis.defuzzifier(domain(var)) do x
            reduce(fis.aggregator, rule[y](x) for rule in rules if haskey(rule, y))
        end
    end
end

(fis::MamdaniFuzzySystem)(; inputs...) = fis(values(inputs))

function (fis::SugenoFuzzySystem)(inputs::T) where {T <: NamedTuple}
    S = float(eltype(T))
    res = Dictionary{Symbol, S}(keys(fis.outputs),
                                zeros(float(eltype(T)), length(fis.outputs)))
    weights_sum = zero(S)
    for rule in fis.rules
        w = rule.antecedent(fis, inputs)::S
        weights_sum += w
        for con in rule.consequent
            res[con.subj] += w * memberships(fis.outputs[con.subj])[con.prop](inputs)
        end
    end
    map(Base.Fix2(/, weights_sum), res)
end

(fis::SugenoFuzzySystem)(; inputs...) = fis(values(inputs))
