using FuzzyLogic
using Documenter

DocMeta.setdocmeta!(FuzzyLogic, :DocTestSetup, :(using FuzzyLogic);
                    recursive = true)

makedocs(;
         modules = [FuzzyLogic], authors = "Luca Ferranti",
         sitename = "FuzzyLogic.jl", doctest = false,
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://lucaferranti.github.io/FuzzyLogic.jl"),
         pages = ["Home" => "index.md"])

deploydocs(; repo = "github.com/lucaferranti/FuzzyLogic.jl", push_preview = true)
