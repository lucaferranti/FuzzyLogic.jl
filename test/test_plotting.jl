using FuzzyLogic
using FuzzyLogic: Domain, Variable
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

@testset "Plotting Mamdani inference system" begin
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

    rec = RecipesBase.apply_recipe(Dict{Symbol, Any}(), fis)

    dom_in = Domain(0, 10)
    dom_out = Domain(0, 30)
    data = [
        (GaussianMF(0.0, 1.5), dom_in),
        (TrapezoidalMF(-2, 0, 1, 3), dom_in),
        (TriangularMF(0, 5, 10), dom_out),
        (GaussianMF(5.0, 1.5), dom_in),
        (),
        (TriangularMF(10, 15, 20), dom_out),
        (GaussianMF(10.0, 1.5), dom_in),
        (TrapezoidalMF(7, 9, 10, 12), dom_in),
        (TriangularMF(20, 25, 30), dom_out),
    ]

    titles = [
        "service is poor",
        "food is rancid",
        "tip is cheap",
        "service is good",
        "",
        "tip is average",
        "service is excellent",
        "food is delicious",
        "tip is generous",
    ]

    for (p, d, t) in zip(rec, data, titles)
        @test p.args == d
        if isempty(d)
            @test p.plotattributes == Dict(:plot_title => "tipper", :grid => false,
                       :legend => false, :axis => false, :layout => (3, 3))
        else
            @test p.plotattributes ==
                  Dict(:plot_title => "tipper", :title => t, :layout => (3, 3))
        end
    end
end
