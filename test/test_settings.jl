using FuzzyLogic
using Test

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

@testset "test defuzzifiers" begin
    N = 800
    mf = TrapezoidalMF(1, 2, 5, 7)
    x = LinRange(0, 8, N + 1)
    y = mf.(x)
    @test BisectorDefuzzifier(N)(y, FuzzyLogic.Domain(0, 8)) ≈ 3.75
    @test CentroidDefuzzifier(N)(y, FuzzyLogic.Domain(0, 8)) ≈ 3.7777777777777772
end
