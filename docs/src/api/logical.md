# Logical connectives

## Conjuction methods

```@autodocs
Modules = [FuzzyLogic]
Filter = t -> typeof(t) === DataType && t <: FuzzyLogic.AbstractAnd
```

## Disjunction methods

```@autodocs
Modules = [FuzzyLogic]
Filter = t -> typeof(t) === DataType && t <: FuzzyLogic.AbstractOr
```

## Implication methods

```@autodocs
Modules = [FuzzyLogic]
Filter = t -> typeof(t) === DataType && t <: FuzzyLogic.AbstractImplication
```