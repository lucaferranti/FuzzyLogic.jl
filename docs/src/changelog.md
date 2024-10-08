# Release Notes

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- ![](https://img.shields.io/badge/BREAKING-red.svg) use a different type parameter for each field of membership functions. This allows membership functions to support mixed-type inputs like `GaussianMF(0, 0.1)`.

## v0.1.3 -- 2024-09-18

[view release on GitHub](https://github.com/lucaferranti/FuzzyLogic.jl/releases/tag/v0.1.3)

- ![](https://img.shields.io/badge/bugfix-purple.svg) fix bug in Julia code generation of ZShape and SShape mf
- ![](https://img.shields.io/badge/bugfix-purple.svg) disallow implicit conversion from interval to float
- ![](https://img.shields.io/badge/new%20feature-green.svg) added semi-elliptic and singleton membership functions
- ![](https://img.shields.io/badge/new%20feature-green.svg) added `gensurf` to plot generating surface
- ![](https://img.shields.io/badge/bugfix-purple.svg) fix plotting of systems with several rules and membership functions.
- ![](https://img.shields.io/badge/bugfix-purple.svg) fix plotting of Type-2 systems

## v0.1.2 -- 2023-03-12

[view release on GitHub](https://github.com/lucaferranti/FuzzyLogic.jl/releases/tag/v0.1.2)

- ![](https://img.shields.io/badge/new%20feature-green.svg) support for weighted rules.
- ![](https://img.shields.io/badge/new%20feature-green.svg) allow to specify input and output variables as vectors (e.g. `x[1:10]`) and support for loops to avoid repetitive code.
- ![](https://img.shields.io/badge/new%20feature-green.svg) added support for type-2 membership functions and type-2 systems.
- ![](https://img.shields.io/badge/new%20feature-green.svg) added parser for Fuzzy Markup Language.
- ![](https://img.shields.io/badge/new%20feature-green.svg) added generation of native Julia code.
- ![](https://img.shields.io/badge/enhancement-blue.svg) added left maximum, right maximum and mean of maxima defuzzifiers.

## v0.1.1 -- 2023-02-25

[view release on GitHub](https://github.com/lucaferranti/FuzzyLogic.jl/releases/tag/v0.1.1)

- ![](https://img.shields.io/badge/new%20feature-green.svg) Added fuzzy c-means
- ![](https://img.shields.io/badge/enhancement-blue.svg) added Lukasiewicz, drastic, nilpotent and Hamacher T-norms and corresponding S-norms.
- ![](https://img.shields.io/badge/enhancement-blue.svg) dont build anonymous functions during mamdani inference, but evaluate output directly. Now defuzzifiers don't take a function as input, but an array.
- ![](https://img.shields.io/badge/enhancement-blue.svg) added piecewise linear membership function
- ![](https://img.shields.io/badge/new%20feature-green.svg) added parser for Fuzzy Control Language and matlab fis.

## v0.1.0 -- 2023-01-10

**initial public release**

- initial domain specific language design and parser
- initial membership functions: triangular, trapezoidal, gaussian, bell, linear, sigmoid, sum of sigmoids, product of sigmoids, s-shaped, z-shaped, pi-shaped.
- initial implementation of Mamdani and Sugeno inference systems (type 1)
  - min and prod t-norms with corresponding conorms
  - min and prod implication
  - max and probabilistic sum aggregation method
  - centroid and bisector defuzzifier
  - linear and constant output for Sugeno
- initial plotting functionalities
  - plotting variables and membership functions
  - plotting rules of fuzzy inference system

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/new%20feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg