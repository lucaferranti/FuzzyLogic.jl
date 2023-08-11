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
include("tojulia.jl")
include("readwrite.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, SingletonMF, TrapezoidalMF, TriangularMF, SShapeMF, ZShapeMF, PiShapeMF,
       SemiEllipticMF, PiecewiseLinearMF, WeightedMF, Type2MF, ..,
       ProdAnd, MinAnd, LukasiewiczAnd, DrasticAnd, NilpotentAnd, HamacherAnd, EinsteinAnd,
       ProbSumOr, MaxOr, BoundedSumOr, DrasticOr, NilpotentOr, EinsteinOr, HamacherOr,
       MinImplication, ProdImplication,
       MaxAggregator, ProbSumAggregator,
       CentroidDefuzzifier, BisectorDefuzzifier, LeftMaximumDefuzzifier,
       RightMaximumDefuzzifier, MeanOfMaximaDefuzzifier,
       KarnikMendelDefuzzifier, EKMDefuzzifier, IASCDefuzzifier, EIASCDefuzzifier,
       @mamfis, MamdaniFuzzySystem, @sugfis, SugenoFuzzySystem, set,
       LinearSugenoOutput, ConstantSugenoOutput,
       fuzzy_cmeans,
       compilefis,
       readfis

## parsers

include("parsers/fcl.jl")
include("parsers/matlab_fis.jl")
include("parsers/fml.jl")
@reexport using .FCLParser
@reexport using .MatlabParser
@reexport using .FMLParser

end
