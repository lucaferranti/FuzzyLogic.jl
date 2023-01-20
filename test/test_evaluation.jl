using FuzzyLogic, Test

@testset "test Mamdani evaluation" begin
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

    @test fis(service = 1, food = 2)[:tip]≈5.55 atol=1e-2
    @test fis(service = 3, food = 5)[:tip]≈12.21 atol=1e-2
    @test fis(service = 2, food = 7)[:tip]≈7.79 atol=1e-2
    @test fis(service = 3, food = 1)[:tip]≈8.95 atol=1e-2
end

@testset "test Sugeno evaluation" begin
    fis = @sugfis function tipper(service, food)::tip
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
            cheap = 5.002
            average = 15
            generous = 24.998
        end

        service == poor || food == rancid --> tip == cheap
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end
    @test fis(service = 2, food = 3)[:tip]≈7.478 atol=1e-3
end
