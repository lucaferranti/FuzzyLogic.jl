# FuzzyLogic.jl

|**Info**|**Build status**|**Documentation**|**Contributing**|
|:------:|:--------------:|:---------------:|:--------------:|
|[![version](https://juliahub.com/docs/FuzzyLogic/version.svg)](https://github.com/lucaferranti/FuzzyLogic.jl/releases/latest)|[![CI Status](https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml?query=branch%3Amain)|[![Stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://lucaferranti.github.io/FuzzyLogic.jl/stable/)|[![contributing guidelines](https://img.shields.io/badge/Contributor-Guide-blueviolet)](https://lucaferranti.github.io/FuzzyLogic.jl/dev/contributing)|
|[![Licese: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://github.com/lucaferranti/FuzzyLogic.jl/blob/main/LICENSE)|[![Coverage](https://codecov.io/gh/lucaferranti/FuzzyLogic.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lucaferranti/FuzzyLogic.jl)|[![Dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://lucaferranti.github.io/FuzzyLogic.jl/dev/)|[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)|
|[![downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/FuzzyLogic&label=downloads)](https://pkgs.genieframework.com/?packages=FuzzyLogic)|[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/F/FuzzyLogic.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/F/FuzzyLogic.html)||[![gitter-chat](https://badges.gitter.im/badge.svg)](https://app.gitter.im/#/room/#FuzzyLogic-jl:gitter.im)|

A Julia library for fuzzy inference.

## Installation

To install the package, open a Julia session and run

```julia
using Pkg; Pkg.add("FuzzyLogic")
```

the package can then be loaded with

```julia
using FuzzyLogic
```

## Features

- **Rich!** Mamdani and Sugeno Type-1 inference systems, several membership functions and algoritms options available.
- **Expressive!** Clear Domain Specific Language to write your model as human readable Julia code
- **Productive!** Several visualization tools to help debug and tune your model.

## Quickstart example

```julia
fis = @mamfis function tipper(service, food)::tip
    service := begin
      domain = 0:10
      poor = GaussianMF(0.0, 1.5)
      good = GaussianMF(5.0, 1.5)
      excellent = GaussianMF(10.0, 1.5)
    end

    food := begin
      domain = 0:10
      rancid = TrapezoidalMF(-2, 0, 1, 3)
      delicious = TrapezoidalMF(7, 9, 10, 12)
    end

    tip := begin
      domain = 0:30
      cheap = TriangularMF(0, 5, 10)
      average = TriangularMF(10, 15, 20)
      generous = TriangularMF(20, 25, 30)
    end

    service == poor || food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous
end

fis(service=1, food=2)
```

## Copyright

- Copyright (c) 2022 [Luca Ferranti](https://github.com/lucaferranti)