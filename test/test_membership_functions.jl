using FuzzyLogic, Test

@testset "Difference of sigmoids MF" begin
    f = DifferenceSigmoidMF(5, 2, 5, 7)
    @test f(5)≈1 atol=1e-3
    @test f(4)≈1 atol=1e-3
    @test f(10)≈0 atol=1e-3
    @test f(10)≈0 atol=1e-3
end

@testset "Linear MF" begin
    f = LinearMF(4, 6)
    @test f(3) == 0
    @test f(4) == 0
    @test f(5) == 0.5
    @test f(6) == 1
    @test f(7) == 1

    g = LinearMF(6, 4)
    @test g(3) == 1
    @test g(4) == 1
    @test g(5) == 0.5
    @test g(6) == 0
    @test g(7) == 0
end

@testset "Generalized Bell MF" begin
    f = GeneralizedBellMF(2, 4, 6)
    @test f(0)≈0 atol=1e-3
    @test f(4) == 0.5
    @test f(6) == 1
    @test f(8) == 0.5
end

@testset "Gaussian MF" begin
    f = GaussianMF(5, 2)
    @test f(3) == 1 / √ℯ
    @test f(5) == 1
    @test f(7) == 1 / √ℯ
end

@testset "Product of sigmoids MF" begin
    f = ProductSigmoidMF(2, 3, -5, 8)
    f1 = SigmoidMF(2, 3)
    f2 = SigmoidMF(-5, 8)
    for val in 2:2:8
        @test f(val) ≈ f1(val) * f2(val)
    end
end

@testset "Sigmoid MF" begin
    f = SigmoidMF(2, 4)
    @test f(4) == 0.5
    @test f(9)≈1 atol=1e-3
    @test f(0)≈0 atol=1e-3
    @test f(2) == 1 / (1 + exp(4))
end

@testset "Trapezoidal MF" begin
    f = TrapezoidalMF(1, 5, 7, 8)
    @test f(0) == 0
    @test f(1) == 0
    @test f(3) == 0.5
    @test f(5) == 1
    @test f(6) == 1
    @test f(7) == 1
    @test f(8) == 0
    @test f(9) == 0
end

@testset "Triangular MF" begin
    f = TriangularMF(3, 6, 8)
    @test f(2) == 0
    @test f(3) == 0
    @test f(4.5) == 0.5
    @test f(6) == 1
    @test f(7) == 0.5
    @test f(8) == 0
    @test f(9) == 0
end
