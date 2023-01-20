using Dictionaries, FuzzyLogic, Test
using FuzzyLogic: FuzzyRelation, FuzzyAnd, FuzzyOr, FuzzyRule

# TODO: write more low level tests

@testset "test Mamdani parser" begin
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

        and = ProdAnd
        or = ProbSumOr
        implication = ProdImplication

        service == poor && food == rancid --> tip == cheap
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous

        aggregator = ProbSumAggregator
        defuzzifier = BisectorDefuzzifier
    end

    @test fis isa
          MamdaniFuzzySystem{ProdAnd, ProbSumOr, ProdImplication, ProbSumAggregator,
                             BisectorDefuzzifier}
    @test fis.name == :tipper

    service = Variable(Domain(0, 10),
                       Dictionary([:poor, :good, :excellent],
                                  [GaussianMF(0.0, 1.5), GaussianMF(5.0, 1.5),
                                      GaussianMF(10.0, 1.5)]))

    food = Variable(Domain(0, 10),
                    Dictionary([:rancid, :delicious],
                               [TrapezoidalMF(-2, 0, 1, 3), TrapezoidalMF(7, 9, 10, 12)]))

    tip = Variable(Domain(0, 30),
                   Dictionary([:cheap, :average, :generous],
                              [
                                  TriangularMF(0, 5, 10),
                                  TriangularMF(10, 15, 20),
                                  TriangularMF(20, 25, 30),
                              ]))

    @test fis.inputs == Dictionary([:service, :food], [service, food])
    @test fis.outputs == Dictionary([:tip], [tip])

    @test fis.rules ==
          [
        FuzzyRule(FuzzyAnd(FuzzyRelation(:service, :poor), FuzzyRelation(:food, :rancid)),
                  [FuzzyRelation(:tip, :cheap)]),
        FuzzyRule(FuzzyRelation(:service, :good), [FuzzyRelation(:tip, :average)]),
        FuzzyRule(FuzzyOr(FuzzyRelation(:service, :excellent),
                          FuzzyRelation(:food, :delicious)),
                  [FuzzyRelation(:tip, :generous)]),
    ]
end

@testset "test Sugeno parser" begin
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
            cheap = 0
            average = food
            generous = 2service, food, -2
        end

        service == poor && food == rancid --> tip == cheap
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end

    @test fis isa
          SugenoFuzzySystem{ProdAnd, ProbSumOr}

    @test fis.name == :tipper

    mfs = Dictionary([:cheap, :average, :generous],
                     [
                         ConstantSugenoMF(0),
                         LinearSugenoMF(Dictionary([:service, :food], [0, 1]), 0),
                         LinearSugenoMF(Dictionary([:service, :food], [2, 1]), -2),
                     ])

    @test fis.outputs[:tip].mfs == mfs
end
