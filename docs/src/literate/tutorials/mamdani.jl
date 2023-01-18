
#=
# Build a Mamdani inference system

This tutorial gives a general overiew of FuzzyLogic.jl basic functionalities by showing how
to implement and use a type-1 Mamdani inference system.

DOWNLOAD_NOTE

## Setup

To follow the tutorial, you should have [installed Julia](https://julialang.org/downloads/).

Next, you can install `FuzzyLogic.jl` with

```julia
using Pkg; Pkg.add("FuzzyLogic")
```

## Building the inference system

First, we need to load the library.
=#

using FuzzyLogic

# The Mamdani inference system can be constructed with the [`@fis`](@ref) macro.
# We will first give a full example and then explain every step.

fis = @fis function tipper(service, food)::tip
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

    and = ProdAnd
    or = ProbSumOr
    implication = ProdImplication

    service == poor || food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous

    aggregator = ProbSumAggregator
    defuzzifier = BisectorDefuzzifier
end

#=
As you can see, defining a fuzzy inference system with `@fis` looks a lot like writing
Julia code. Let us now take a closer look at the components. The first line

```julia
function tipper(service, food)::tip
```

specifies the basic properties of the system, particularly

- the function name `tipper` will be the name of the system
- the input arguments `service, food` represent the input variables of the system
- the output type annotation `::tip` represents the output variable of the system. If the system has multiple outputs, they should be enclosed in braces, i.e. `::{tip1, tip2}`

The next block is the variable specifications block, identified by the `:=` operator.
This block is used to specify the domain and membership functions of a variable, for example

```julia
service := begin
    domain = 0:10
    poor = GaussianMF(0.0, 1.5)
    good = GaussianMF(5.0, 1.5)
    excellent = GaussianMF(10.0, 1.5)
end
```

The order of the statements inside the `begin ... end` block is irrelevant.

- The line `domain = 0:10` sets the domain of the variable to the interval ``[0, 10]``. Note that setting the domain is required

- The other lines specify the membership functions of the variable.
For example, `poor = GaussianMF(0.0, 1.5)` means that the variable has a Gaussian
membership function called `poor` with mean ``0.0`` and stanrdard devisation ``1.5``.
A complete list of supported dmembership functions and their parameters can be found in the
[Membership functions](@ref) section of the API documentation.

Next, we describe rule blocks. A fuzzy relation such as `service is poor` is described with
the `==` operator, for example `service == poor`.
The *premise* i.e. left-hand side, of the rule can be any logical proposition connecting
fuzzy relations with the `&&` (AND) and `||` (OR) operators. The *consequence* i.e. right-hand side,
of the rule is a fuzzy relation for the output variable. Premise and consequence are connected with
the `-->` operator. For example, the rule

```julia
service == poor || food == rancid --> tip == cheap
```

reads *If the service is poor or the food is rancid, then the tip is cheap*.

Note that in the premise can be any logical proposition, you can have both `&&` and  `||` connectives
and you can also have nested propositions. For example, the following is a valid rule

```julia
service == poor || food = rancid && service == good
```

The connectives follow Julia precedence rules, so `&&` binds stronger than `||`.

If you have multiple outputs, then the consequence should be a tuple, for example

```julia
service == poor || food == rancid --> (tip1 == cheap, tip2 == cheap)
```

Finally, assignment lines like

```julia
and = ProdAnd
```

are used to set the settings of the inference system. For a Mamdani inference system,
the following settings are available

- `and`: algorithm to evaluate `&&`. Must be one of the available [Conjuction methods](@ref).
- `or`: algorithm to evaluate `||`. Must be one of the available [Disjunction methods](@ref).
- `implication`: algorithm to evalute `-->`. Must be one of the available [Implication methods](@ref).
- `aggregato`: algorithm to perform outputs aggregation. Must be one of the available [Aggregation methods](@ref).
- `defuzzifier`: algorithm to perform defuzzification. Must be one of the available [Defuzzification methods](@ref).

Each of the previous settings has a default value that will be used if the setting is not specified.
The default values are listed in [`FuzzyInferenceSystem`](@ref) documentation.

Some of the above settings may have internal parameters.
For example, [`CentroidDefuzzifier`](@ref) has an integer parameter `N`, the number of points used to perform numerical integration.
If the parameter is not specified, as in `defuzzifier = CentroidDefuzzifier`, then the default value for `N` can be used.
This parameter can be overwritten with custom values, for example

```julia
defuzzifier = CentroidDefuzzifier(50)
```

will use ``50`` as value of `N` instead of the default one (``100`` in this case).

## Visualization

The library offers tools to visualize your fuzzy inference system. This requires installing
and importing the `Plots.jl` library.
=#

using Plots

#=
The membership functions of a given variable can be plotted by calling `plot(fis, varname)`,
where `fis` is the inference system you created and `varname` is the name of the variable you
want to visualize, given as a symbol. For example,
=#

plot(fis, :service)

# Giving only the inference system object to `plot` will plot the inference rules, one per line.

plot(fis)

#=
## Inference

To perform inference, you can call the above constructed inference system as a function, passing th input values as parameters.
Note that the system does not accept positional arguments, but inputs should be passed as name-value pairs.
For example
=#

res = fis(service = 2, food = 3)

# The result is a Dictionary containing the output value corresponding to each output variable.
# The value of a specific output variable can be extracted using the variable name as key.

res[:tip]
