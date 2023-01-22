# FuzzyLogic.jl

|**Info**|**Build status**|**Documentation**|**Contributing**|
|:------:|:--------------:|:---------------:|:--------------:|
|[![version][ver-img]][ver-url]|[![CI Status][ci-img]][ci-url]|[![Stable docs][stable-img]][stable-url]|[![contributing guidelines][contrib-img]][contrib-url]|
|[![Licese: MIT][license-img]][license-url]|[![Coverage][cov-img]][cov-url]|[![Dev docs][dev-img]][dev-url]|[![SciML Code Style][style-img]][style-url]|

A Julia library for fuzzy inference.

## Installation

To install the package, open a Julia session and run

```julia
using Pkg; Pkg.add(url="https://github.com/lucaferranti/FuzzyLogic.jl.git")
```

the package can then be loaded with

```julia
using FuzzyLogic
```

## Roadmap

- **Rich!** Mamdani and Sugeno inference systems, both Type-1 and Type-2, several [membership functions](https://lucaferranti.github.io/FuzzyLogic.jl/stable/api/memberships) and [algoritms options](https://lucaferranti.github.io/FuzzyLogic.jl/stable/api/fis) available.
- **Compatible!** Able to read/write your model from/to [IEEE 1855-2016 Fuzzy Markup Language](https://en.wikipedia.org/wiki/Fuzzy_markup_language) and [IEC 61131-7 Fuzzy Control Language](https://ffll.sourceforge.net/fcl.htm) and Matlab Fuzzy toolbox `.fis` files.
- **Expressive!** Clear Domain Specific Language to write your model as human readable Julia code
- **Productive!** Several visualization tools to help debug and tune your model.
- **Portable!** Compile your final model to Julia or C/C++ code.

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

fis(; service=1, food=2)
```

## Documentation

- [**STABLE**][stable-url]: Documentation of the latest release
- [**DEV**][dev-url]: Documentation of the version on main

## Contributing

Contributions are welcome! If you find a bug or want to request a feature, [open an issue](https://github.com/lucaferranti/FuzzyLogic.jl/issues). You are also encouraged to send pull requests (PRs). For small changes, it is ok to open a PR directly. For bigger changes, it is advisable to discuss it in an issue first. Before opening a PR, make sure to check the [contributing guidelines](https://lucaferranti.github.io/FuzzyLogic.jl/dev/contributing).

## Copyright

- Copyright (c) 2022 [Luca Ferranti](https://github.com/lucaferranti)

[ver-img]: https://img.shields.io/badge/lifecycle-maturing-important
[ver-url]: #

[license-img]: https://img.shields.io/badge/license-MIT-yellow.svg
[license-url]: https://github.com/lucaferranti/FuzzyLogic.jl/blob/main/LICENSE

[stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[stable-url]:https://lucaferranti.github.io/FuzzyLogic.jl/stable/

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://lucaferranti.github.io/FuzzyLogic.jl/dev/

[ci-img]: https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml/badge.svg?branch=main
[ci-url]: https://github.com/lucaferranti/FuzzyLogic.jl/actions/workflows/CI.yml?query=branch%3Amain

[cov-img]: https://codecov.io/gh/lucaferranti/FuzzyLogic.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/lucaferranti/FuzzyLogic.jl

[contrib-img]: https://img.shields.io/badge/Contributor-Guide-important
[contrib-url]: https://lucaferranti.github.io/FuzzyLogic.jl/dev/contributing

[style-img]: https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826
[style-url]: https://github.com/SciML/SciMLStyle