using Documenter, FuzzyInference, Test

DocMeta.setdocmeta!(FuzzyInference, :DocTestSetup, :(using FuzzyInference);
                    recursive = true)

doctest(FuzzyInference; manual = false)
