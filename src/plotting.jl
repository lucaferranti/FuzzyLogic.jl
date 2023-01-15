using RecipesBase

# plot membership function
@recipe function f(mf::AbstractMembershipFunction, low::Real, high::Real)
    legend --> nothing
    x -> mf(x), low, high
end

@recipe f(mf::AbstractMembershipFunction, dom::Domain) = mf, low(dom), high(dom)

# plot variables
@recipe function f(var::Variable, varname::Union{Symbol, Nothing} = nothing)
    if !isnothing(varname)
        title --> string(varname)
    end
    dom = domain(var)
    mfs = memberships(var)
    legend --> true
    for (name, mf) in pairs(mfs)
        @series begin
            label --> string(name)
            mf, dom
        end
    end
    nothing
end

@recipe function f(fis::FuzzyInferenceSystem, varname::Symbol)
    if haskey(fis.inputs, varname)
        fis.inputs[varname], varname
    elseif haskey(fis.outputs, varname)
        fis.outputs[varname], varname
    end
end

# plot fis

@recipe function f(fis::FuzzyInferenceSystem)
    plot_title := string(fis.name)
    nout = length(fis.outputs)
    nin = length(fis.inputs)
    nrules = length(fis.rules)
    layout := (nrules, nin + nout)
    for rule in fis.rules
        ants = leaves(rule.antecedent)
        for (varname, var) in pairs(fis.inputs)
            idx = findall(x -> subject(x) == varname, ants)
            length(idx) > 1 &&
                throw(ArgumentError("Cannot plot repeated variables in rules"))

            @series if length(idx) == 1
                rel = ants[first(idx)]
                title := string(rel)
                var.mfs[predicate(rel)], var.domain
            else
                foreground_color_subplot --> :transparent
                color --> :transparent
                grid --> false
                axis --> false
                identity
            end
        end

        for (varname, var) in pairs(fis.outputs)
            idx = findall(x -> subject(x) == varname, rule.consequent)
            length(idx) > 1 &&
                throw(ArgumentError("Cannot plot repeated variables in rules"))

            @series if length(idx) == 1
                rel = rule.consequent[first(idx)]
                title := string(rel)
                var.mfs[predicate(rel)], var.domain
            else
                foreground_color_subplot --> :transparent
                color --> :transparent
                grid --> false
                axis --> false
                identity
            end
        end
    end
end
