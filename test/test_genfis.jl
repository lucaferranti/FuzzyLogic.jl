using FuzzyLogic, Test

@testset "fuzzy c-means" begin
    data = zeros(2, 1500)
    for (i, line) in enumerate(eachline(joinpath(@__DIR__, "data", "cmeans_data.txt")))
        data[:, i] = parse.(Float64, split(line, ","))
    end

    C, U = fuzzy_cmeans(data, 3; m = 3)

    @test sortslices(C; dims = 2)≈[-9.89855 5.03523 14.9183; 5.05589 4.88728 14.9307] atol=1e-3
end
