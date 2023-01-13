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
