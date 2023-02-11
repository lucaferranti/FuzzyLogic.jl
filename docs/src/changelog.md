# Release Notes

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## unreleased

- ![][badge-feature] Added fuzzy c-means
- ![][badge-enhancement] added support Lukasiewicz, drastic, nilpotent and Hamacher T-norms and corresponding S-norms.

## v0.1.0 -- 2023-01-10

[view release on GitHub](https://github.com/lucaferranti/FuzzyLogic.jl/releases/tag/v0.1.0)

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