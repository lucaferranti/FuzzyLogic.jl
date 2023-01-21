module FuzzyLogic

using Dictionaries

include("docstrings.jl")
include("membership_functions.jl")
include("variables.jl")
include("rules.jl")
include("options.jl")
include("InferenceSystem.jl")
include("parser.jl")
include("evaluation.jl")
include("plotting.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF, SShapeMF, ZShapeMF, PiShapeMF,
       ProdAnd, MinAnd, ProbSumOr, MaxOr, MinImplication, ProdImplication,
       MaxAggregator, ProbSumAggregator, CentroidDefuzzifier, BisectorDefuzzifier,
       @mamfis, MamdaniFuzzySystem, @sugfis, SugenoFuzzySystem,
       LinearSugenoOutput, ConstantSugenoOutput
end
