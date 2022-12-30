# Fuzzy inference system options

## T-Norms

abstract type AbstractAnd end

struct MinAnd <: AbstractAnd end
struct ProdAnd <: AbstractAnd end

## S-Norms

abstract type AbstractOr end

struct MaxOr <: AbstractOr end
struct ProbSumOr <: AbstractOr end

## Implication

abstract type AbstractImplication end

struct MinImplication <: AbstractImplication end
struct ProdImplication <: AbstractImplication end

## Aggregation

abstract type AbstractAggregator end

struct MaxAggregator <: AbstractAggregator end
struct ProbSumAggregator <: AbstractAggregator end

## Defuzzification

abstract type AbstractDefuzzifier end

struct CentroidDefuzzifier <: AbstractDefuzzifier end
struct BisectorDefuzzifier <: AbstractDefuzzifier end

## Defaults

const DEFAULT_AND = MinAnd()
const DEFAULT_OR = MaxOr()
const DEFAULT_IMPLICATION = MinImplication()
const DEFAULT_AGGREGATOR = MaxAggregator()
const DEFAULT_DEFUZZIFIER = CentroidDefuzzifier()
