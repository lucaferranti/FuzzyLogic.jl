using FuzzyLogic, Test

@testset "fuzzy c-means" begin
    X = [-3 -3 -3 -2 -2 -2 -1 0 1 2 2 2 3 3 3;
         -2 0 2 -1 0 1 0 0 0 -1 0 1 -2 0 2]
    C, U = fuzzy_cmeans(X, 2; m = 3)
    @test sortslices(C; dims = 2)≈[-2.02767 2.02767; 0 0] atol=1e-3
    @test_throws ArgumentError fuzzy_cmeans(X, 3; m = 1)
end
