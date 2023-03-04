using FuzzyLogic, Test
using FuzzyLogic: Interval, inf, sup, mid, diam

@testset "interval operations" begin
    a = Interval(0.1, 1.0)
    b = Interval(0.2, 0.8)

    @test inf(a) == 0.1
    @test sup(a) == 1.0
    @test mid(a) ≈ 0.55
    @test inf(0.1) == sup(0.1) == mid(0.1) == 0.1
    @test diam(a) ≈ 0.9
    @test diam(0.1) == 0.0

    @test Interval(1.0, 2.0) ≈ Interval(nextfloat(1.0), prevfloat(2.0))
    @test +a == a
    @test -a == Interval(-1.0, -0.1)
    @test a + b ≈ Interval(0.3, 1.8)
    @test a - b ≈ Interval(-0.7, 0.8)
    @test a * b ≈ Interval(0.02, 0.8)
    @test a / b ≈ Interval(0.125, 5.0)
    @test min(a, b) == Interval(0.1, 0.8)
    @test max(a, b) == Interval(0.2, 1.0)
    @test zero(Interval{Float64}) == Interval(0.0, 0.0)

    @test convert(Interval{Float64}, 1.0) == Interval(1.0, 1.0)
    @test convert(Float64, Interval(0.0, 1.0)) == 0.5
    @test float(Interval{BigFloat}) == BigFloat
end
