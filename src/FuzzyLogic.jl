module FuzzyLogic

using Dictionaries, DocStringExtensions, MacroTools

include("docstrings.jl")
include("membership_functions.jl")
include("variables.jl")
include("rules.jl")
include("options.jl")
include("InferenceSystem.jl")
include("parser.jl")
include("evaluation.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF,
       ProdAnd, MinAnd, ProbSumOr, MaxOr, MinImplication, ProdImplication,
       MaxAggregator, ProbSumAggregator, CentroidDefuzzifier, BisectorDefuzzifier,
       FuzzyRule, FuzzyAnd, FuzzyOr, FuzzyRelation,
       @fis, FuzzyInferenceSystem, Domain, Variable
end
