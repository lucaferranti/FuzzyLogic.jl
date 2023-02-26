# Data structure to describe fuzzy rules.

abstract type AbstractFuzzyProposition end

"""
Describes a fuzzy relation like "food is good".
"""
struct FuzzyRelation <: AbstractFuzzyProposition
    "subject of the relation."
    subj::Symbol
    "property of the relation."
    prop::Symbol
end
Base.show(io::IO, fr::FuzzyRelation) = print(io, fr.subj, " is ", fr.prop)
subject(fr::FuzzyRelation) = fr.subj
predicate(fr::FuzzyRelation) = fr.prop

"""
Describes a fuzzy relation like "food is good".
"""
struct FuzzyNegation <: AbstractFuzzyProposition
    "subject of the relation."
    subj::Symbol
    "property of the relation."
    prop::Symbol
end
Base.show(io::IO, fr::FuzzyNegation) = print(io, fr.subj, " is not ", fr.prop)
subject(fr::FuzzyNegation) = fr.subj
predicate(fr::FuzzyNegation) = fr.prop

"""
Describes the conjuction of two propositions.
"""
struct FuzzyAnd{T <: AbstractFuzzyProposition, S <: AbstractFuzzyProposition} <:
       AbstractFuzzyProposition
    left::T
    right::S
end
Base.show(io::IO, fa::FuzzyAnd) = print(io, '(', fa.left, " ∧ ", fa.right, ')')

"""
Describe disjunction of two propositions.
"""
struct FuzzyOr{T <: AbstractFuzzyProposition, S <: AbstractFuzzyProposition} <:
       AbstractFuzzyProposition
    left::T
    right::S
end
Base.show(io::IO, fo::FuzzyOr) = print(io, '(', fo.left, " ∨ ", fo.right, ')')

abstract type AbstractRule end

"""
Describes a fuzzy implication rule IF antecedent THEN consequent.
"""
struct FuzzyRule{T <: AbstractFuzzyProposition} <: AbstractRule
    "premise of the inference rule."
    antecedent::T
    "consequences of the inference rule."
    consequent::Vector{FuzzyRelation}
end
Base.show(io::IO, r::FuzzyRule) = print(io, r.antecedent, " --> ", r.consequent...)

"""
Weighted fuzzy rule. In Mamdani systems, the result of implication is scaled by the weight.
In Sugeno systems, the result of the antecedent is scaled by the weight.
"""
struct WeightedFuzzyRule{T <: AbstractFuzzyProposition, S <: Real} <: AbstractRule
    "premise of the inference rule."
    antecedent::T
    "consequences of the inference rule."
    consequent::Vector{FuzzyRelation}
    "weight of the rule."
    weight::S
end

function Base.show(io::IO, r::WeightedFuzzyRule)
    print(io, r.antecedent, " --> ", r.consequent..., " (", r.weight, ")")
end

@inline scale(w, ::FuzzyRule) = w
@inline scale(w, r::WeightedFuzzyRule) = w * r.weight

# comparisons (for testing)

Base.:(==)(r1::FuzzyRelation, r2::FuzzyRelation) = r1.subj == r2.subj && r1.prop == r2.prop
Base.:(==)(r1::FuzzyNegation, r2::FuzzyNegation) = r1.subj == r2.subj && r1.prop == r2.prop

function Base.:(==)(p1::T, p2::T) where {T <: AbstractFuzzyProposition}
    p1.left == p2.left && p1.right == p2.right
end
Base.:(==)(p1::AbstractFuzzyProposition, p2::AbstractFuzzyProposition) = false

function Base.:(==)(r1::FuzzyRule, r2::FuzzyRule)
    r1.antecedent == r2.antecedent && r1.consequent == r1.consequent
end

function Base.:(==)(r1::WeightedFuzzyRule, r2::WeightedFuzzyRule)
    r1.antecedent == r2.antecedent && r1.consequent == r1.consequent &&
        r1.weight == r2.weight
end

# utilities
leaves(fr::Union{FuzzyNegation, FuzzyRelation}) = (fr,)
leaves(fp::AbstractFuzzyProposition) = [leaves(fp.left)..., leaves(fp.right)...]
