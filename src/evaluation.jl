# utilities to evaluate a fuzzy inference system

function (fr::FuzzyRelation)(fis::FuzzyInferenceSystem, inputs)
    memberships(fis.inputs[fr.subj])[fr.prop](inputs[fr.subj])
end

function (fa::FuzzyAnd)(fis::FuzzyInferenceSystem, inputs)
    fis.and(fa.left(fis, inputs), fa.right(fis, inputs))
end

function (fo::FuzzyOr)(fis::FuzzyInferenceSystem, inputs)
    fis.or(fo.left(fis, inputs), fo.right(fis, inputs))
end

function (fr::FuzzyRule)(fis::FuzzyInferenceSystem, inputs)
    map(fr.consequent) do c
        mf = memberships(fis.outputs[c.subj])[c.prop]
        c.subj => y -> fis.implication(fr.antecedent(fis, inputs), mf(y))
    end |> dictionary
end

function (fis::FuzzyInferenceSystem)(; inputs...)
    rules = [rule(fis, inputs) for rule in fis.rules]
    map(pairs(fis.outputs)) do (y, var)
        fis.defuzzifier(domain(var)) do x
            reduce(fis.aggregator, rule[y](x) for rule in rules if haskey(rule, y))
        end
    end
end
