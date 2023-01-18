ENV["GKSwstype"] = "100"

const IS_CI = get(ENV, "CI", "false") == "true"

import Pkg

if !IS_CI
    Pkg.activate(@__DIR__)
    Pkg.instantiate()
end

Pkg.add(Pkg.PackageSpec(name = "Documenter", rev = "30baed5")) # TODO remove once Documenter 0.28 is released

using Documenter
using DocThemeIndigo
using FuzzyLogic
using Literate

###############################
# GENERATE LITERATE NOTEBOOKS #
###############################

const jldir = joinpath(@__DIR__, "src", "literate") # input directory for literate scripts.
const mddir = joinpath(@__DIR__, "src") # output directory for markdown files.
const nbdir = joinpath(@__DIR__, "src", "notebooks") # output directory for notebooks.

# fix edit links (only locally)
function fix_edit_link(content)
    replace(content,
            "EditURL = \"<unknown>" => "EditURL = \"https://github.com/lucaferranti/FuzzyLogic.jl/blob/main")
end

# Adds link from markdown to notebook.
# Points to local path locally and to nbviewer when deployed.
notebook_link(file) = content -> notebook_link(file, content)
function notebook_link(file, content)
    root = IS_CI ? "@__NBVIEWER_ROOT_URL__" :
           "https://nbviewer.org/github/lucaferranti/FuzzyLogic.jl/blob/gh-pages/dev"
    path = joinpath(root, "notebooks", replace(file, ".jl" => ".ipynb"))
    note = """!!! tip "Try it yourself!"\n    Read this as Jupyter notebook [here]($path)"""
    replace(content, "DOWNLOAD_NOTE" => note)
end

for (root, _, files) in walkdir(jldir), file in files
    endswith(file, ".jl") || continue
    ipath = joinpath(root, file)
    opath = splitdir(replace(ipath, jldir => mddir))[1]
    Literate.markdown(ipath, opath;
                      preprocess = notebook_link(file),
                      postprocess = IS_CI ? identity : fix_edit_link,
                      credit = false)

    Literate.notebook(ipath, nbdir; execute = IS_CI, credit = false)
end

###############
# CREATE HTML #
###############

makedocs(;
         modules = [FuzzyLogic], authors = "Luca Ferranti",
         sitename = "FuzzyLogic.jl",
         doctest = false,
         format = Documenter.HTML(;
                                  assets = [DocThemeIndigo.install(FuzzyLogic)],
                                  prettyurls = IS_CI, collapselevel = 1,
                                  canonical = "https://lucaferranti.github.io/FuzzyLogic.jl"),
         pages = [
             "Home" => "index.md",
             "Tutorials" => [
                 "Build a Mamdani inference system" => "tutorials/mamdani.md",
             ],
             "API" => [
                 "Inference system" => "api/fis.md",
                 "Membership functions" => "api/memberships.md",
             ],
             "Contributor's Guide" => "contributing.md",
             "Release notes" => "changelog.md",
         ])

##########
# DEPLOY #
##########

if IS_CI
    deploydocs(; repo = "github.com/lucaferranti/FuzzyLogic.jl", push_preview = true)
end
