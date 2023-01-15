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

"""
Describes a fuzzy implication rule IF antecedent THEN consequent.
"""
struct FuzzyRule{T <: AbstractFuzzyProposition}
    "premise of the inference rule."
    antecedent::T
    "consequences of the premise rule."
    consequent::Vector{FuzzyRelation}
end
Base.show(io::IO, r::FuzzyRule) = print(io, r.antecedent, " --> ", r.consequent...)

# comparisons (for testing)

Base.:(==)(r1::FuzzyRelation, r2::FuzzyRelation) = r1.subj == r2.subj && r1.prop == r2.prop

function Base.:(==)(p1::T, p2::T) where {T <: AbstractFuzzyProposition}
    p1.left == p2.left && p1.right == p2.right
end
Base.:(==)(p1::AbstractFuzzyProposition, p2::AbstractFuzzyProposition) = false

function Base.:(==)(r1::FuzzyRule, r2::FuzzyRule)
    r1.antecedent == r2.antecedent && r1.consequent == r1.consequent
end

# utilities
leaves(fr::FuzzyRelation) = (fr,)
leaves(fp::AbstractFuzzyProposition) = [leaves(fp.left)..., leaves(fp.right)...]
