#=
# Build a Sugeno inference system

This tutorial describes how to construct a type-1 Sugeno inference system.
The reader is assumed to be familiar with the basic syntax to build an inference syntax, which
is described in the [Build a Mamdani inference system](@ref) tutorial.

DOWNLOAD_NOTE

Similarly to Mamdani, a Sugeno inference system can be built using the [`@sugfis`](@ref) macro.
The following example shows the macro in action

=#
using FuzzyLogic, Plots

fis = @sugfis function tipper(service, food)::tip
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
        cheap = 5.002
        average = 15
        generous = 2service, 0.5food, 5.0
    end

    service == poor || food == rancid --> tip == cheap
    service == good --> tip == average
    service == excellent || food == delicious --> tip == generous
end

#=
The results is an object of type [`SugenoFuzzySystem`](@ref). This similar to a Mamdani inference system, with the main difference being in
the output definition.
In a Sugeno system, the output "membership function" can be:

- a constant output, e.g. `average = 15`. This means that if the tip is average, then it has value ``15``,
- an affine combination of the inputs, e.g. ``generous = 2service, 0.5food, 5.0``. This means that if the tip is generous, then it will have output value ``2service+0.5food + 5.0``.

It is good to highlight that this functions return the value of the output variable and not a membership degree, like in a Mamdani system.

The second difference from a Mandani system is the settings that cab be tuned. A Sugeno system has only the following options:

- `and`: algorithm to evaluate `&&`. Must be one of the available [Conjuction methods](@ref). Default [`ProdAnd`](@ref).
- `or`: algorithm to evaluate `||`. Must be one of the available [Disjunction methods](@ref). Default [`ProbSumOr`](@ref)

The created model can be evaluated the same way of a Mamdani system.

=#

fis(service = 2, food = 3)

# Let's see how to plot the output variables, as it differs from the Mamdani system

plot(fis, :tip)

#=
As you can see

- If the membership function is constant, then the plot simply shows a horizontal line at the output value level
- For `LinearSugenoOutput`, the plot is a bar plot, showing for each input variable the corresponding coefficient.
  This gives a visual indication of how much each input contributes to the output.

Like the Mamdani case, we can plot the whole system.
=#

plot(fis)
