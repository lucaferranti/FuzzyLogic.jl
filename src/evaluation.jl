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
        c.subj => Base.Fix1(fis.implication, fr.antecedent(fis, inputs)) ∘ mf
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
