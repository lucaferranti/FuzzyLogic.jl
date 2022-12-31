using FuzzyLogic
using Documenter

makedocs(;
         modules = [FuzzyLogic], authors = "Luca Ferranti",
         sitename = "FuzzyLogic.jl", doctest = false,
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://lucaferranti.github.io/FuzzyLogic.jl"),
         pages = [
             "Home" => "index.md",
             "API" => [
                 "Inference system" => "api/fis.md",
                 "Membership functions" => "api/memberships.md",
             ],
             "Contributor's Guide" => "contributing.md",
         ])

deploydocs(; repo = "github.com/lucaferranti/FuzzyLogic.jl", push_preview = true)
