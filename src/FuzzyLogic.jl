module FuzzyLogic

using Dictionaries, DocStringExtensions, MacroTools

include("docstrings.jl")
include("membership_functions.jl")
include("rules.jl")
include("options.jl")
include("InferenceSystem.jl")
include("parser.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF,
       FuzzyRule, FuzzyAnd, FuzzyOr, FuzzyRelation,
       @fis, FuzzyInferenceSystem, Domain
end
