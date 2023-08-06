import Pkg

Pkg.activate(@__DIR__)
Pkg.develop(Pkg.PackageSpec(path = joinpath(@__DIR__, "..")))
Pkg.instantiate()

# TODO remove once Documenter 0.28 is released
# this is to get both the edit link and a the github link
Pkg.add(Pkg.PackageSpec(name = "Documenter", rev = "30baed5"))
