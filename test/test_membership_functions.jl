using FuzzyLogic, Test
using FuzzyLogic: Interval, to_expr

@testset "Difference of sigmoids MF" begin
    f = DifferenceSigmoidMF(5, 2, 5, 7)
    @test f(5)≈1 atol=1e-3
    @test f(4)≈1 atol=1e-3
    @test f(10)≈0 atol=1e-3

    @test eval(to_expr(f, 5))≈1 atol=1e-3
    @test eval(to_expr(f, 4))≈1 atol=1e-3
    @test eval(to_expr(f, 10))≈0 atol=1e-3
end

@testset "Linear MF" begin
    f = LinearMF(4, 6)
    @test f(3) == eval(to_expr(f, 3)) == 0
    @test f(4) == eval(to_expr(f, 4)) == 0
    @test f(5) == eval(to_expr(f, 5)) == 0.5
    @test f(6) == eval(to_expr(f, 6)) == 1
    @test f(7) == eval(to_expr(f, 7)) == 1

    g = LinearMF(6, 4)
    @test g(3) == eval(to_expr(g, 3)) == 1
    @test g(4) == eval(to_expr(g, 4)) == 1
    @test g(5) == eval(to_expr(g, 5)) == 0.5
    @test g(6) == eval(to_expr(g, 6)) == 0
    @test g(7) == eval(to_expr(g, 7)) == 0
end

@testset "Generalized Bell MF" begin
    f = GeneralizedBellMF(2, 4, 6)
    @test f(0) ≈ eval(to_expr(f, 0)) ≈ 0.00015239256324291374
    @test f(4) == eval(to_expr(f, 4)) == 0.5
    @test f(6) == eval(to_expr(f, 6)) == 1
    @test f(8) == eval(to_expr(f, 8)) == 0.5
end

@testset "Gaussian MF" begin
    f = GaussianMF(5, 2)
    @test f(3) == eval(to_expr(f, 3)) == 1 / √ℯ
    @test f(5) == eval(to_expr(f, 5)) == 1
    @test f(7) == eval(to_expr(f, 7)) == 1 / √ℯ
end

@testset "Product of sigmoids MF" begin
    f = ProductSigmoidMF(2, 3, -5, 8)
    f1 = SigmoidMF(2, 3)
    f2 = SigmoidMF(-5, 8)
    for val in 2:2:8
        @test f(val) ≈ eval(to_expr(f, val)) ≈ f1(val) * f2(val)
    end
end

@testset "Sigmoid MF" begin
    f = SigmoidMF(2, 4)
    @test f(4) == eval(to_expr(f, 4)) == 0.5
    @test f(9) == eval(to_expr(f, 9)) == 1 / (1 + exp(-10))
    @test f(0) == eval(to_expr(f, 0)) == 1 / (1 + exp(8))
    @test f(2) == eval(to_expr(f, 2)) == 1 / (1 + exp(4))
end

@testset "Singleton MF" begin
    f = SingletonMF(4)
    @test f(4) === eval(to_expr(f, 4)) === 1
    @test f(4.0) === eval(to_expr(f, 4.0)) === 1.0
    @test iszero(f(3))
    @test iszero(eval(to_expr(f, 3)))
    @test iszero(f(5))
end

@testset "Trapezoidal MF" begin
    f = TrapezoidalMF(1, 5, 7, 8)
    @test f(0) == eval(to_expr(f, 0)) == 0
    @test f(1) == eval(to_expr(f, 1)) == 0
    @test f(3) == eval(to_expr(f, 3)) == 0.5
    @test f(5) == eval(to_expr(f, 5)) == 1
    @test f(6) == eval(to_expr(f, 6)) == 1
    @test f(7) == eval(to_expr(f, 7)) == 1
    @test f(8) == eval(to_expr(f, 8)) == 0
    @test f(9) == eval(to_expr(f, 9)) == 0
end

@testset "Triangular MF" begin
    f = TriangularMF(3, 6, 8)
    @test f(2) == eval(to_expr(f, 2)) == 0
    @test f(3) == eval(to_expr(f, 3)) == 0
    @test f(4.5) == eval(to_expr(f, 4.5)) == 0.5
    @test f(6) == eval(to_expr(f, 6)) == 1
    @test f(7) == eval(to_expr(f, 7)) == 0.5
    @test f(8) == eval(to_expr(f, 8)) == 0
    @test f(9) == eval(to_expr(f, 9)) == 0
end

@testset "S-shaped MF" begin
    mf = SShapeMF(1, 8)
    @test mf(0) == eval(to_expr(mf, 0)) == 0
    @test mf(1) == eval(to_expr(mf, 1)) == 0
    @test mf(2.75) ≈ eval(to_expr(mf, 2.75)) ≈ 0.125
    @test mf(4.5) ≈ eval(to_expr(mf, 4.5)) ≈ 0.5
    @test mf(6.25) ≈ eval(to_expr(mf, 6.25)) ≈ 0.875
    @test mf(8) == eval(to_expr(mf, 8)) == 1
    @test mf(9) == eval(to_expr(mf, 9)) == 1
end

@testset "Z-shaped MF" begin
    mf = ZShapeMF(3, 7)
    @test mf(2) == eval(to_expr(mf, 2)) == 1
    @test mf(3) == eval(to_expr(mf, 3)) == 1
    @test mf(4) ≈ eval(to_expr(mf, 4)) ≈ 0.875
    @test mf(5) ≈ eval(to_expr(mf, 5)) ≈ 0.5
    @test mf(6) ≈ eval(to_expr(mf, 6)) ≈ 0.125
    @test mf(7) == eval(to_expr(mf, 7)) == 0
    @test mf(9) == eval(to_expr(mf, 9)) == 0
end

@testset "Pi-shaped MF" begin
    mf = PiShapeMF(1, 4, 5, 10)
    @test mf(1) == eval(to_expr(mf, 1)) == 0
    @test mf(2.5) == eval(to_expr(mf, 2.5)) == 0.5
    @test mf(4) == eval(to_expr(mf, 4)) == 1
    @test mf(4.5) == eval(to_expr(mf, 4.5)) == 1
    @test mf(5) == eval(to_expr(mf, 5)) == 1
    @test mf(7.5) == eval(to_expr(mf, 7.5)) == 0.5
    @test mf(8.75) == eval(to_expr(mf, 8.75)) == 0.125
    @test mf(10) == eval(to_expr(mf, 10)) == 0
end

@testset "Semi-Elliptic MF" begin
    mf = SemiEllipticMF(5.0, 4.0)
    @test mf(0) == eval(to_expr(mf, 0)) == 0
    @test mf(1) == eval(to_expr(mf, 1)) == 0
    @test mf(5) == eval(to_expr(mf, 5)) == 1
    @test mf(9) == eval(to_expr(mf, 9)) == 0
    @test mf(10) == eval(to_expr(mf, 10)) == 0
end

@testset "Piecewise linear Membership function" begin
    mf = PiecewiseLinearMF([(1, 0), (2, 1), (3, 0), (4, 0.5), (5, 0), (6, 1)])
    @test mf(0.0) == eval(to_expr(mf, 0.0)) == 0
    @test mf(1.0) == eval(to_expr(mf, 1.0)) == 0
    @test mf(1.5) == eval(to_expr(mf, 1.5)) == 0.5
    @test mf(2) == eval(to_expr(mf, 2)) == 1
    @test mf(3.5) == eval(to_expr(mf, 3.5)) == 0.25
    @test mf(7) == eval(to_expr(mf, 7)) == 1
end

@testset "Weighted Membership function" begin
    mf = TriangularMF(1, 2, 3)
    mf1 = 0.5 * mf
    mf2 = mf * 0.5
    @test mf1(1) == mf2(1) == eval(to_expr(mf1, 1)) == 0
    @test mf1(3) == mf2(3) == eval(to_expr(mf1, 3)) == 0
    @test mf1(2) == mf2(2) == eval(to_expr(mf1, 2)) == 0.5
    @test mf1(0.3) == mf2(0.3) == eval(to_expr(mf1, 0.3)) == 0.5 * mf(0.3)
end

@testset "Type-2 membership function" begin
    mf = 0.5 * TriangularMF(1, 2, 3) .. TriangularMF(0, 2, 4)
    @test mf(-1) == Interval(0.0, 0.0)
    @test mf(0) == Interval(0.0, 0.0)
    @test mf(1) == Interval(0.0, 0.5)
    @test mf(1.5) == Interval(0.25, 0.75)
    @test mf(2) == Interval(0.5, 1.0)
    @test mf(3) == Interval(0.0, 0.5)
    @test mf(4) == Interval(0.0, 0.0)
    @test mf(5) == Interval(0.0, 0.0)
end

@testset "Mixed argument types" begin
    mf = TriangularMF(1, 2.0, 3.0f0)
    @test typeof(mf) == TriangularMF{Int64, Float64, Float32}

    mf = TrapezoidalMF(1, 2.0, 3, 4.0)
    @test typeof(mf) == TrapezoidalMF{Int64, Float64, Int64, Float64}
end
