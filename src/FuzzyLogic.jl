module FuzzyLogic

using Dictionaries, Reexport

include("docstrings.jl")
include("membership_functions.jl")
include("variables.jl")
include("rules.jl")
include("options.jl")
include("InferenceSystem.jl")
include("parser.jl")
include("evaluation.jl")
include("plotting.jl")
include("genfis.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF, SShapeMF, ZShapeMF, PiShapeMF,
       PiecewiseLinearMF,
       ProdAnd, MinAnd, LukasiewiczAnd, DrasticAnd, NilpotentAnd, HamacherAnd,
       ProbSumOr, MaxOr, BoundedSumOr, DrasticOr, NilpotentOr, EinsteinOr,
       MinImplication, ProdImplication,
       MaxAggregator, ProbSumAggregator, CentroidDefuzzifier, BisectorDefuzzifier,
       @mamfis, MamdaniFuzzySystem, @sugfis, SugenoFuzzySystem,
       LinearSugenoOutput, ConstantSugenoOutput,
       fuzzy_cmeans

## parsers

include("parsers/fcl.jl")

@reexport using .FCLParser

end
