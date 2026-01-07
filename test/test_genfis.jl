using FuzzyLogic, Random, LinearAlgebra, Test

function generate_cluster(μ::Vector{Float64}, σ::Matrix{Float64}, n::Int)
    return cholesky(Symmetric(σ)).L * randn(2, n) .+ μ
end

@testset "fuzzy c-means" begin
    X = [-3 -3 -3 -2 -2 -2 -1 0 1 2 2 2 3 3 3;
         -2 0 2 -1 0 1 0 0 0 -1 0 1 -2 0 2]
    C, U = fuzzy_cmeans(X, 2; m = 3)
    @test sortslices(C; dims = 2)≈[-2.02767 2.02767; 0 0] atol=1e-3
    @test_throws ArgumentError fuzzy_cmeans(X, 3; m = 1)
end

@testset "Gustafson-Kessel" begin
    Random.seed!(5)
    μ1 = [-2; 1.0]
    μ2 = [6.0; 3]
    X1 = generate_cluster(μ1, diagm(fill(0.25, 2)), 200)

    θ = π / 4
    U = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    D = Diagonal([5, 0.25])

    Σ = U * D * U'

    X2 = generate_cluster(fill(0.0, 2), Σ, 300)
    X3 = generate_cluster(-μ1, diagm(fill(0.5, 2)), 200)
    X4 = generate_cluster(μ2, diagm(fill(0.1, 2)), 200)

    X = hcat(X1, X2, X3, X4)

    Random.seed!()
    (C, U) = gustafson_kessel(X, 4; α = 2)

    @test sortslices(
        C, dims = 2)≈[-1.98861 -0.08146 2.00787 5.94698; 1.04687 -0.03456 -0.95882 3.02226] atol=1e-3
    @test_throws ArgumentError gustafson_kessel(X, 4; α = 1)
    @test_throws ArgumentError gustafson_kessel(X, 4; ρ = [1, 1, 1])
    @test_throws ArgumentError gustafson_kessel(X, 4, γ = 2)
end
