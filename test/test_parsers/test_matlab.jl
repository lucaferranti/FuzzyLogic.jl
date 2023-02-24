using Dictionaries, FuzzyLogic, PEG, Test
using FuzzyLogic: Variable, Domain, FuzzyRelation, FuzzyAnd, FuzzyOr, FuzzyNegation,
                  FuzzyRule

@testset "parse Mamdani infernce system" begin
    fis1 = matlabfis"""
    [System]
    Name='tipper'
    Type='mamdani'
    NumInputs=2
    NumOutputs=1
    NumRules=3
    AndMethod='min'
    OrMethod='max'
    ImpMethod='min'
    AggMethod='max'
    DefuzzMethod='centroid'

    [Input1]
    Name='service'
    Range=[0 10]
    NumMFs=3
    MF1='poor':'gaussmf',[1.5 0]
    MF2='good':'gaussmf',[1.5 5]
    MF3='excellent':'gaussmf',[1.5 10]

    [Input2]
    Name='food'
    Range=[0 10]
    NumMFs=2
    MF1='rancid':'trapmf',[-2 0 1 3]
    MF2='delicious':'trapmf',[7 9 10 12]

    [Output1]
    Name='tip'
    Range=[0 30]
    NumMFs=3
    MF1='cheap':'trimf',[0 5 10]
    MF2='average':'trimf',[10 15 20]
    MF3='generous':'trimf',[20 25 30]

    [Rules]
    1 1, 1 (1) : 2
    2 0, 2 (1) : 1
    3 2, 3 (1) : 2
    """

    fis2 = readfis(joinpath(@__DIR__, "data", "tipper.fis"))
    for fis in (fis1, fis2)
        @test fis isa MamdaniFuzzySystem{MinAnd, MaxOr, MinImplication, MaxAggregator,
                                 CentroidDefuzzifier}
        @test fis.name == :tipper

        service = Variable(Domain(0.0, 10.0),
                           Dictionary([:poor, :good, :excellent],
                                      [GaussianMF(0.0, 1.5), GaussianMF(5.0, 1.5),
                                          GaussianMF(10.0, 1.5)]))

        food = Variable(Domain(0.0, 10.0),
                        Dictionary([:rancid, :delicious],
                                   [
                                       TrapezoidalMF(-2.0, 0.0, 1.0, 3.0),
                                       TrapezoidalMF(7.0, 9.0, 10.0, 12.0),
                                   ]))

        tip = Variable(Domain(0.0, 30.0),
                       Dictionary([:cheap, :average, :generous],
                                  [
                                      TriangularMF(0.0, 5.0, 10.0),
                                      TriangularMF(10.0, 15.0, 20.0),
                                      TriangularMF(20.0, 25.0, 30.0),
                                  ]))

        @test fis.inputs == Dictionary([:service, :food], [service, food])
        @test fis.outputs == Dictionary([:tip], [tip])

        @test fis.rules ==
              [
            FuzzyRule(FuzzyOr(FuzzyRelation(:service, :poor),
                              FuzzyRelation(:food, :rancid)),
                      [FuzzyRelation(:tip, :cheap)]),
            FuzzyRule(FuzzyRelation(:service, :good), [FuzzyRelation(:tip, :average)]),
            FuzzyRule(FuzzyOr(FuzzyRelation(:service, :excellent),
                              FuzzyRelation(:food, :delicious)),
                      [FuzzyRelation(:tip, :generous)]),
        ]
    end
end
