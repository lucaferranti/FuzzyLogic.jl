import Pkg

Pkg.activate(@__DIR__)
Pkg.develop(Pkg.PackageSpec(path = joinpath(@__DIR__, "..")))
Pkg.instantiate()
