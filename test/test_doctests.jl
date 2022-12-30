using Documenter, FuzzyLogic, Test

DocMeta.setdocmeta!(FuzzyLogic, :DocTestSetup, :(using FuzzyLogic);
                    recursive = true)

doctest(FuzzyLogic; manual = false)
