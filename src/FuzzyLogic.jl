module FuzzyLogic

using Dictionaries, Reexport

include("docstrings.jl")
include("intervals.jl")
include("membership_functions.jl")
include("variables.jl")
include("rules.jl")
include("options.jl")
include("InferenceSystem.jl")
include("parser.jl")
include("evaluation.jl")
include("plotting.jl")
include("genfis.jl")
include("readwrite.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF, SShapeMF, ZShapeMF, PiShapeMF,
       PiecewiseLinearMF, WeightedMF, Type2MF, ..,
       ProdAnd, MinAnd, LukasiewiczAnd, DrasticAnd, NilpotentAnd, HamacherAnd,
       ProbSumOr, MaxOr, BoundedSumOr, DrasticOr, NilpotentOr, EinsteinOr,
       MinImplication, ProdImplication,
       MaxAggregator, ProbSumAggregator, CentroidDefuzzifier, BisectorDefuzzifier,
       KarnikMendelDefuzzifier,
       @mamfis, MamdaniFuzzySystem, @sugfis, SugenoFuzzySystem,
       LinearSugenoOutput, ConstantSugenoOutput,
       fuzzy_cmeans,
       readfis

## parsers

include("parsers/fcl.jl")
include("parsers/matlab_fis.jl")
@reexport using .FCLParser
@reexport using .MatlabParser

end
