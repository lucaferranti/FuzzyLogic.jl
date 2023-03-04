# Defuzzification methods

## Type-1 defuzzifiers
```@autodocs
Modules = [FuzzyLogic]
Filter = t -> typeof(t) === DataType && t <: FuzzyLogic.AbstractDefuzzifier && !(t <: FuzzyLogic.Type2Defuzzifier)
```

## Type-2 defuzzifiers

```@autodocs
Modules = [FuzzyLogic]
Filter = t -> typeof(t) === DataType && t <: FuzzyLogic.Type2Defuzzifier
```
