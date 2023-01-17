# Release Notes

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.0 -- 2023-01-10

[view release on GitHub](https://github.com/lucaferranti/FuzzyLogic.jl/releases/tag/v0.1.0)

**initial public release**

- initial domain specific language design and parser
- initial membership functions: triangular, trapezoidal, gaussian, bell, linear, sigmoid, sum of sigmoids, product of sigmoids.
- initial implementation of Mamdani and Sugeno inference systems (type 1)
  - min, prod and Łukasiewicz t-norms with corresponding conorms
  - min and prod implication
  - max and probabilistic sum aggregation method
  - centroid and bisector defuzzifier
- initial plotting functionalities
  - plotting variables and membership functions
  - plotting rules of fuzzy inference system