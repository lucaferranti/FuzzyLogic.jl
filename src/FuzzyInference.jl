module FuzzyInference

using DocStringExtensions

include("docstrings.jl")
include("membership_functions.jl")

export DifferenceSigmoidMF, LinearMF, GeneralizedBellMF, GaussianMF, ProductSigmoidMF,
       SigmoidMF, TrapezoidalMF, TriangularMF
end
