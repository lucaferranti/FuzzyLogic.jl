# utilities to evaluate a fuzzy inference system

function (fr::FuzzyRelation)(fis::FuzzyInferenceSystem, inputs)
    fis.mfs[fr.prop](inputs[fr.subj])
end

function (fa::FuzzyAnd)(fis::FuzzyInferenceSystem, inputs)
    fis.and(fa.left(fis, inputs), fa.right(fis, inputs))
end

function (fo::FuzzyOr)(fis::FuzzyInferenceSystem, inputs)
    fis.or(fo.left(fis, inputs), fo.right(fis, inputs))
end

function (fr::FuzzyRule)(fis::FuzzyInferenceSystem, inputs)
    map(fr.consequent) do c
        c.subj => y -> fis.implication(fr.antecedent(fis, inputs), fis.mfs[c.prop](y))
    end |> dictionary
end

function (fis::FuzzyInferenceSystem)(; inputs...)
    rules = [rule(fis, inputs) for rule in fis.rules]

    map(pairs(fis.outputs)) do (y, dom)
        fis.defuzzifier(dom) do x
            reduce(fis.aggregator, rule[y](x) for rule in rules if haskey(rule, y))
        end
    end
end
