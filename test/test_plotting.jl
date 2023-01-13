using FuzzyLogic
using RecipesBase
using Dictionaries
using Test

@testset "Plotting variables" begin
    mf1 = TriangularMF(1, 2, 3)
    mf2 = TrapezoidalMF(1, 2, 3, 4)
    dom = Domain(0, 5)

    rec = RecipesBase.apply_recipe(Dict{Symbol, Any}(), mf1, dom)
    @test isempty(only(rec).plotattributes)
    @test only(rec).args == (mf1, 0, 5)

    rec = RecipesBase.apply_recipe(Dict{Symbol, Any}(), mf1, 0, 5)
    @test only(rec).plotattributes == Dict(:legend => nothing)
    @test only(rec).args[2:3] == (0, 5)
    @test only(rec).args[1](0) == mf1(0)

    mfnames = [:mf1, :mf2]
    mfs = [mf1, mf2]
    var = Variable(dom, Dictionary(mfnames, mfs))
    rec = RecipesBase.apply_recipe(Dict{Symbol, Any}(), var, :var)
    @test length(rec) == 2
    for i in 1:2
        @test rec[i].plotattributes ==
              Dict(:legend => true, :label => string(mfnames[i]), :title => "var")
        @test rec[i].args == (mfs[i], dom)
    end
end
