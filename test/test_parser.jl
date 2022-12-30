using FuzzyInference, Test
using FuzzyInference: Domain, ProdAnd, ProbSumOr, ProdImplication, ProbSumAggregator,
                      BisectorDefuzzifier
using Dictionaries

@testset "test parser" begin
    fis = @fis function tipper(service in 0:10, food in 0:10)::{tip in 0:30}
        poor = GaussianMF(1.5, 0.0)
        good = GaussianMF(1.5, 5.0)
        excellent = GaussianMF(1.5, 10.0)

        rancid = TrapezoidalMF(-2, 0, 1, 3)
        delicious = TrapezoidalMF(7, 9, 10, 12)

        cheap = TriangularMF(0, 5, 10)
        average = TriangularMF(10, 15, 20)
        generous = TriangularMF(20, 25, 30)

        and = ProdAnd
        or = ProbSumOr
        implication = ProdImplication

        service == poor || food == rancid => tip == cheap
        service == good => tip == average
        service == excellent || food == delicious => tip == generous

        aggregator = ProbSumAggregator
        defuzzifier = BisectorDefuzzifier
    end

    @test fis isa
          FuzzyInferenceSystem{ProdAnd, ProbSumOr, ProdImplication, ProbSumAggregator,
                               BisectorDefuzzifier}
    @test fis.name == :tipper
    @test fis.inputs == Dictionary([:service, :food], [Domain(0, 10), Domain(0, 10)])
    @test fis.outputs == Dictionary([:tip], [Domain(0, 30)])
    @test fis.mfs == Dictionary([
                         :poor,
                         :good,
                         :excellent,
                         :rancid,
                         :delicious,
                         :cheap,
                         :average,
                         :generous,
                     ],
                     [
                         GaussianMF(1.5, 0.0),
                         GaussianMF(1.5, 5.0),
                         GaussianMF(1.5, 10.0),
                         TrapezoidalMF(-2, 0, 1, 3),
                         TrapezoidalMF(7, 9, 10, 12),
                         TriangularMF(0, 5, 10),
                         TriangularMF(10, 15, 20),
                         TriangularMF(20, 25, 30),
                     ])
end
