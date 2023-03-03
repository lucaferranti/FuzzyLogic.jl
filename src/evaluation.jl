# utilities to evaluate a fuzzy inference system

function (fr::FuzzyRelation)(fis::AbstractFuzzySystem,
                             inputs::T) where {T <: NamedTuple}
    memberships(fis.inputs[fr.subj])[fr.prop](inputs[fr.subj])
end

function (fr::FuzzyNegation)(fis::AbstractFuzzySystem,
                             inputs::T)::float(eltype(T)) where {T <: NamedTuple}
    1 - memberships(fis.inputs[fr.subj])[fr.prop](inputs[fr.subj])
end

function (fa::FuzzyAnd)(fis::AbstractFuzzySystem, inputs)
    fis.and(fa.left(fis, inputs), fa.right(fis, inputs))
end

function (fo::FuzzyOr)(fis::AbstractFuzzySystem, inputs)
    fis.or(fo.left(fis, inputs), fo.right(fis, inputs))
end

function (fr::FuzzyRule)(fis::AbstractFuzzySystem, inputs;
                         N = 100)
    map(fr.consequent) do c
        l, h = low(fis.outputs[c.sub].domain), high(fis.outputs[c.sub].domain)
        mf = broadcast(memberships(fis.outputs[c.subj])[c.prop], LinRange(l, h, N))
        broadcast(implication(fis), fr.antecedent(fis, inputs), mf)
    end
end

function (fis::MamdaniFuzzySystem)(inputs::T) where {T <: NamedTuple}
    Npoints = fis.defuzzifier.N + 1
    S = outputtype(typeof(fis.defuzzifier), T)
    res = Dictionary{Symbol, Vector{S}}(keys(fis.outputs),
                                        [zeros(S, Npoints) for _ in 1:length(fis.outputs)])
    @inbounds for rule in fis.rules
        w = rule.antecedent(fis, inputs)
        for con in rule.consequent
            var = fis.outputs[con.subj]
            l, h = low(var.domain), high(var.domain)
            mf = map(var.mfs[con.prop], LinRange(l, h, Npoints))
            ruleres = scale(broadcast(implication(fis), w, mf), rule)
            res[con.subj] = broadcast(fis.aggregator, res[con.subj], ruleres)
        end
    end

    Dictionary{Symbol, float(S)}(keys(fis.outputs), map(zip(res, fis.outputs)) do (y, var)
                                     fis.defuzzifier(y, var.domain)
                                 end)
end

(fis::MamdaniFuzzySystem)(; inputs...) = fis(values(inputs))
@inline function (fis::MamdaniFuzzySystem)(inputs::Union{AbstractVector, Tuple})
    fis((; zip(collect(keys(fis.inputs)), inputs)...))
end

function (fis::SugenoFuzzySystem)(inputs::T) where {T <: NamedTuple}
    S = float(eltype(T))
    res = Dictionary{Symbol, S}(keys(fis.outputs),
                                zeros(float(eltype(T)), length(fis.outputs)))
    weights_sum = zero(S)
    for rule in fis.rules
        w = scale(rule.antecedent(fis, inputs), rule)::S
        weights_sum += w
        for con in rule.consequent
            res[con.subj] += w * memberships(fis.outputs[con.subj])[con.prop](inputs)
        end
    end
    map(Base.Fix2(/, weights_sum), res)
end

(fis::SugenoFuzzySystem)(; inputs...) = fis(values(inputs))
@inline function (fis::SugenoFuzzySystem)(inputs::Union{AbstractVector, Tuple})
    fis((; zip(collect(keys(fis.inputs)), inputs)...))
end

outputtype(::Type{T}, S) where {T <: AbstractDefuzzifier} = float(eltype(S))
outputtype(::Type{T}, S) where {T <: Type2Defuzzifier} = Interval{float(eltype(S))}
