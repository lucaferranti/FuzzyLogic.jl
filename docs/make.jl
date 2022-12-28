using FuzzyInference
using Documenter

DocMeta.setdocmeta!(FuzzyInference, :DocTestSetup, :(using FuzzyInference);
                    recursive = true)

makedocs(;
         modules = [FuzzyInference], authors = "Luca Ferranti",
         sitename = "FuzzyInference.jl",
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://lucaferranti.github.io/FuzzyInference.jl"),
         pages = ["Home" => "index.md"])

deploydocs(; repo = "github.com/lucaferranti/FuzzyInference.jl", push_preview = true)
