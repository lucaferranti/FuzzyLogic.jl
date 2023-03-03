using RecipesBase

# plot membership function
@recipe function f(mf::AbstractMembershipFunction, low::Real, high::Real)
    legend --> nothing
    x -> mf(x), low, high
end

@recipe function f(mf::Type2MF, low::Real, high::Real)
    legend --> nothing
    fillrange := x -> mf.hi(x)
    fillalpha --> 0.25
    x -> mf.lo(x), low, high
end

@recipe f(mf::AbstractPredicate, dom::Domain) = mf, low(dom), high(dom)

# plot sugeno membership functions
@recipe function f(mf::ConstantSugenoOutput, low::Real, high::Real)
    legend --> nothing
    ylims --> (low, high)
    yticks --> [low, mf.c, high]
    xticks --> nothing
    x -> mf(x), low, high
end

@recipe function f(mf::LinearSugenoOutput, low::Real, high::Real)
    legend --> nothing
    line --> :stem
    framestyle --> :origin
    x = 1:2:(2 * length(mf.coeffs) + 2)
    xticks --> (x, push!(collect(keys(mf.coeffs)), :offset))
    xlims --> (0, x[end] + 1)
    x, push!(collect(mf.coeffs), mf.offset)
end

# plot variables
@recipe function f(var::Variable, varname::Union{Symbol, Nothing} = nothing)
    issugeno = first(var.mfs) isa AbstractSugenoOutputFunction
    if !isnothing(varname)
        plot_title --> string(varname)
    end
    dom = domain(var)
    mfs = memberships(var)
    if issugeno
        legend --> false
        layout --> (1, length(var.mfs))
    else
        legend --> true
    end
    for (name, mf) in pairs(mfs)
        @series begin
            if issugeno
                title --> string(name)
            else
                label --> string(name)
            end
            mf, dom
        end
    end
    nothing
end

@recipe function f(fis::AbstractFuzzySystem, varname::Symbol)
    if haskey(fis.inputs, varname)
        fis.inputs[varname], varname
    elseif haskey(fis.outputs, varname)
        fis.outputs[varname], varname
    end
end

# plot fis

@recipe function f(fis::AbstractFuzzySystem)
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
                # TODO: use own recipes for negation and relation
                if rel isa FuzzyNegation
                    legend --> false
                    x -> 1 - var.mfs[predicate(rel)](x), low(var.domain), high(var.domain)
                else
                    var.mfs[predicate(rel)], var.domain
                end
            else
                grid --> false
                axis --> false
                legend --> false
                ()
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
                grid --> false
                axis --> false
                legend --> false
                ()
            end
        end
    end
end
