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

    # with weighted rules and negation
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

        service == poor || food == rancid --> tip == cheap * 0.5
        service == good && food != rancid --> tip == average
        service == excellent || food == delicious --> tip == generous
    end

    @test fis(service = 2, food = 7)[:tip]≈9.36 atol=1e-2
    @test fis([2, 7])[:tip]≈9.36 atol=1e-2
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

        service == poor || food == rancid --> tip == cheap * 0.5
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end
    @test fis(service = 2, food = 3)[:tip]≈8.97 atol=5e-3

    fis2 = @sugfis function tipper(service, food)::tip
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
            generous = 2service, 0.5food, 5.0
        end

        service == poor || food == rancid --> tip == cheap
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end
    @test fis2(service = 7, food = 8)[:tip]≈19.639 atol=1e-3
    @test fis2((7, 8))[:tip]≈19.639 atol=1e-3
end

@testset "Type-2 Mamdani" begin
    fis = @mamfis function tipper(service, food)::tip
        service := begin
            domain = 0:10
            poor = 0.9 * GaussianMF(0.0, 1.2) .. GaussianMF(0.0, 1.5)
            good = 0.9 * GaussianMF(5.0, 1.2) .. GaussianMF(5.0, 1.5)
            excellent = 0.9 * GaussianMF(10.0, 1.2) .. GaussianMF(10.0, 1.5)
        end

        food := begin
            domain = 0:10
            rancid = 0.9 * TrapezoidalMF(-1.8, 0.0, 1.0, 2.8) .. TrapezoidalMF(-2, 0, 1, 3)
            delicious = 0.9 * TrapezoidalMF(8, 9, 10, 12) .. TrapezoidalMF(7, 9, 10, 12)
        end

        tip := begin
            domain = 0:30
            cheap = 0.9 * TriangularMF(1, 5, 9) .. TriangularMF(0, 5, 10)
            average = 0.9 * TriangularMF(11, 15, 19) .. TriangularMF(10, 15, 20)
            generous = 0.9 * TriangularMF(22, 25, 29) .. TriangularMF(20, 25, 30)
        end

        service == poor || food == rancid --> tip == cheap
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous

        defuzzifier = KarnikMendelDefuzzifier()
    end

    for defuzzifier in (KarnikMendelDefuzzifier(), EKMDefuzzifier(), IASCDefuzzifier(),
                        EIASCDefuzzifier())
        fis = set(fis; defuzzifier)
        @test fis(service = 2, food = 3)[:tip]≈7.439 atol=1e-3
    end
end

@testset "Type-2 Sugeno" begin
    fis = @sugfis function tipper(service, food)::tip
        service := begin
            domain = 0:10
            poor = 0.6 * GaussianMF(0.0, 1.5) .. GaussianMF(0.0, 1.5)
            good = 0.6 * GaussianMF(5.0, 1.5) .. GaussianMF(5.0, 1.5)
            excellent = 0.9 * GaussianMF(10.0, 1.5) .. GaussianMF(10.0, 1.5)
        end

        food := begin
            domain = 0:10
            rancid = 0.8 * TrapezoidalMF(-2, 0, 1, 3) .. TrapezoidalMF(-2, 0, 1, 4)
            delicious = 0.8 * TrapezoidalMF(8, 9, 10, 12) .. TrapezoidalMF(7, 9, 10, 12)
        end

        tip := begin
            domain = 0:30
            cheap = 5.002
            average = 15
            generous = 24.998
        end

        service == poor || food == rancid --> tip == cheap * 0.5
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end
    @test fis(service = 2, food = 3)[:tip]≈FuzzyLogic.Interval(2.94, 28.613) atol=1e-3
end
