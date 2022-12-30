module FuzzyInference

using Dictionaries, DocStringExtensions, MacroTools

include("docstrings.jl")
include("membership_functions.jl")
include("options.jl")
include("fis.jl")
include("parser.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF,
       @fis, FuzzyInferenceSystem, Domain
end
