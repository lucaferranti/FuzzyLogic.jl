using FuzzyLogic
using Test

@testset "update fuzzy systems" begin
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

        and = ProdAnd
        or = ProbSumOr
        implication = ProdImplication

        service == poor && food == rancid --> tip == cheap * 0.2
        service == good --> (tip == average, tip == average) * 0.3
        service == excellent || food == delicious --> tip == generous
        service == excellent || food == delicious --> (tip == generous, tip == generous)

        aggregator = ProbSumAggregator
        defuzzifier = BisectorDefuzzifier
    end

    fis2 = set(fis; name = :tipper2, defuzzifier = CentroidDefuzzifier())
    @test fis2.name == :tipper2
    @test fis2 isa
          MamdaniFuzzySystem{ProdAnd, ProbSumOr, ProdImplication, ProbSumAggregator,
                             CentroidDefuzzifier}
end

@testset "test T--norms" begin
    @test MinAnd()(0.4, 0.2) == 0.2
    @test MinAnd()(1.0, 1.0) == 1.0
    @test MinAnd()(0.0, 0.0) == 0.0

    @test ProdAnd()(0.4, 0.2) ≈ 0.08
    @test ProdAnd()(1.0, 1.0) == 1.0
    @test ProdAnd()(0.0, 0.0) == 0.0

    @test DrasticAnd()(1.0, 0.2) == 0.2
    @test DrasticAnd()(0.3, 1.0) == 0.3
    @test DrasticAnd()(0.9, 0.9) == 0.0

    @test LukasiewiczAnd()(0.4, 0.2) == 0
    @test LukasiewiczAnd()(0.7, 0.5) ≈ 0.2
    @test LukasiewiczAnd()(0.5, 0.5) ≈ 0

    @test NilpotentAnd()(0.4, 0.2) == 0.0
    @test NilpotentAnd()(0.5, 0.7) == 0.5
    @test NilpotentAnd()(0.5, 0.5) == 0.0

    @test HamacherAnd()(0.0, 0.0) == 0.0
    @test HamacherAnd()(0.4, 0.2) ≈ 0.15384615384615388
    @test HamacherAnd()(1.0, 1.0) == 1.0
end

@testset "test S-norms" begin
    @test MaxOr()(0.4, 0.2) == 0.4
    @test MaxOr()(1.0, 1.0) == 1.0
    @test MaxOr()(0.0, 0.0) == 0.0

    @test ProbSumOr()(0.5, 0.5) == 0.75
    @test ProbSumOr()(1.0, 0.2) == 1.0
    @test ProbSumOr()(1.0, 0.0) == 1.0

    @test BoundedSumOr()(0.2, 0.3) == 0.5
    @test BoundedSumOr()(0.6, 0.6) == 1.0
    @test BoundedSumOr()(0.0, 0.0) == 0.0

    @test DrasticOr()(0.2, 0.0) == 0.2
    @test DrasticOr()(0.0, 0.2) == 0.2
    @test DrasticOr()(0.01, 0.01) == 1.0

    @test NilpotentOr()(0.2, 0.3) == 0.3
    @test NilpotentOr()(0.5, 0.6) == 1.0
    @test NilpotentOr()(0.7, 0.1) == 0.7

    @test EinsteinOr()(0.0, 0.0) == 0.0
    @test EinsteinOr()(0.5, 0.5) == 0.8
    @test EinsteinOr()(1.0, 1.0) == 1.0
end

@testset "test type-1 defuzzifiers" begin
    N = 800
    mf = TrapezoidalMF(1, 2, 5, 7)
    x = LinRange(0, 8, N + 1)
    y = mf.(x)
    @test BisectorDefuzzifier(N)(y, FuzzyLogic.Domain(0, 8)) ≈ 3.75
    @test CentroidDefuzzifier(N)(y, FuzzyLogic.Domain(0, 8)) ≈ 3.7777777777777772
end
