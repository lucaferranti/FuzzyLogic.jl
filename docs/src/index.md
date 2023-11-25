# FuzzyLogic.jl

|**Info**|**Build status**|**Documentation**|**Contributing**|**Citation**|
|:------:|:--------------:|:---------------:|:--------------:|:----------:|
|[![version](https://juliahub.com/docs/FuzzyLogic/version.svg)](https://github.com/lucaferranti/FuzzyLogic.jl/releases/latest)|[![CI Status](https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml?query=branch%3Amain)|[![Stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://lucaferranti.github.io/FuzzyLogic.jl/stable/)|[![contributing guidelines](https://img.shields.io/badge/Contributor-Guide-blueviolet)](https://lucaferranti.github.io/FuzzyLogic.jl/dev/contributing)|[![bibtex](https://img.shields.io/badge/BibTeX-citation-orange)](https://github.com/lucaferranti/FuzzyLogic.jl/blob/main/CITATION.bib)
|[![Licese: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://github.com/lucaferranti/FuzzyLogic.jl/blob/main/LICENSE)|[![Coverage](https://codecov.io/gh/lucaferranti/FuzzyLogic.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lucaferranti/FuzzyLogic.jl)|[![Dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://lucaferranti.github.io/FuzzyLogic.jl/dev/)|[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)|[![paper](https://img.shields.io/badge/FUZZIEEE-paper-blue)](https://arxiv.org/abs/2306.10316)
|[![downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/FuzzyLogic&label=downloads)](https://pkgs.genieframework.com/?packages=FuzzyLogic)|[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/F/FuzzyLogic.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/F/FuzzyLogic.html)|[![JuliaCon video](https://img.shields.io/badge/JuliaCon-video-red.svg)](https://www.youtube.com/watch?v=6WfX3e-aOBc)|[![gitter-chat](https://badges.gitter.im/badge.svg)](https://app.gitter.im/#/room/#FuzzyLogic-jl:gitter.im)|[![zenodo](https://img.shields.io/badge/Zenodo-archive-blue)](https://doi.org/10.5281/zenodo.7570243)

A Julia library for fuzzy logic and applications.

If you use this in your research, please cite it as

```bibtex
@INPROCEEDINGS{ferranti2023fuzzylogicjl,
  author={Ferranti, Luca and Boutellier, Jani},
  booktitle={2023 IEEE International Conference on Fuzzy Systems (FUZZ)}, 
  title={FuzzyLogic.jl: A Flexible Library for Efficient and Productive Fuzzy Inference}, 
  year={2023},
  pages={1-5},
  doi={10.1109/FUZZ52849.2023.10309777}}
```

## Features

- **Rich!** Mamdani and Sugeno inference systems, both Type-1 and Type-2, several [membership functions](https://lucaferranti.github.io/FuzzyLogic.jl/stable/api/memberships) and [algoritms options](https://lucaferranti.github.io/FuzzyLogic.jl/stable/api/fis) available.
- **Compatible!** Read your models from [IEC 61131-7 Fuzzy Control Language](https://ffll.sourceforge.net/fcl.htm), [IEEE 1855-2016 Fuzzy Markup Language](https://en.wikipedia.org/wiki/Fuzzy_markup_language) and Matlab Fuzzy toolbox `.fis` files.
- **Expressive!** Clear Domain Specific Language to write your model as human readable Julia code
- **Productive!** Several visualization tools to help debug and tune your model.
- **Portable!** Compile your final model to Julia code.

## Installation

1. If you haven't already, install Julia. The easiest way is to install [Juliaup](https://github.com/JuliaLang/juliaup#installation). This allows to easily manage julia versions.

2. Open the terminal and start a julia session by simply typing `julia`

3. Install the library by typing

```julia
using Pkg; Pkg.add("FuzzyLogic")
```

4. The package can now be loaded (in the interactive REPL or in a script file) with the command

```julia
using FuzzyLogic
```

5. That's it, have fun!

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

- Copyright (c) 2022 [Luca Ferranti](https://github.com/lucaferranti), released under MIT license.