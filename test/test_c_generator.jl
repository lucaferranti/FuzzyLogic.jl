using FuzzyLogic
using Test

@testset "Membership functions compilation" begin
    mf = TriangularMF(1, 2, 3)
    @test_broken to_c(mf) == """

    """

    mf = GaussianMF(0.0, 1.5)
    @test_broken to_c(mf) == ""
end
