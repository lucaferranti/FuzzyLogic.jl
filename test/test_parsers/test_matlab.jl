using Dictionaries, FuzzyLogic, PEG, Test
using FuzzyLogic: Variable, Domain, FuzzyRelation, FuzzyAnd, FuzzyOr, FuzzyNegation,
                  WeightedFuzzyRule, FuzzyRule

@testset "parse Mamdani infernce system" begin
    fis = readfis(joinpath(@__DIR__, "data", "tipper.fis"))

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

    fis = matlabfis"""
    [System]
    Name='edgefis'
    Type='mamdani'
    Version=2.0
    NumInputs=2
    NumOutputs=1
    NumRules=2
    AndMethod='min'
    OrMethod='max'
    ImpMethod='min'
    AggMethod='max'
    DefuzzMethod='bisector'

    [Input1]
    Name='Ix'
    Range=[-1 1]
    NumMFs=1
    MF1='zero':'gaussmf',[0.1 0]

    [Input2]
    Name='Iy'
    Range=[-1 1]
    NumMFs=1
    MF1='zero':'gaussmf',[0.1 0]

    [Output1]
    Name='Iout'
    Range=[0 1]
    NumMFs=2
    MF1='white':'linsmf',[0.1 1]
    MF2='black':'linzmf',[0 0.7]

    [Rules]
    1 1, 1 (1) : 1
    -1 -1, 2 (1) : 2
    """

    @test fis isa MamdaniFuzzySystem{MinAnd, MaxOr, MinImplication, MaxAggregator,
                             BisectorDefuzzifier}

    @test fis.outputs[:Iout].mfs ==
          Dictionary([:white, :black], [LinearMF(0.1, 1.0), LinearMF(0.7, 0.0)])

    @test fis.rules[2] ==
          FuzzyRule(FuzzyOr(FuzzyNegation(:Ix, :zero), FuzzyNegation(:Iy, :zero)),
                    [FuzzyRelation(:Iout, :black)])
end

@testset "Test Sugeno inference system" begin
    fis = matlabfis"""
    [System]
    Name='sugfis'
    Type='sugeno'
    Version=2.0
    NumInputs=1
    NumOutputs=1
    NumRules=2
    AndMethod='prod'
    OrMethod='probor'
    ImpMethod='prod'
    AggMethod='sum'
    DefuzzMethod='wtaver'

    [Input1]
    Name='input'
    Range=[-5 5]
    NumMFs=2
    MF1='low':'gaussmf',[4 -5]
    MF2='high':'gaussmf',[4 5]

    [Output1]
    Name='output'
    Range=[0 1]
    NumMFs=2
    MF1='line1':'linear',[-1 -1]
    MF2='line2':'constant',[0.5]

    [Rules]
    1, 1 (0.5) : 1
    2, 2 (0.5) : 1
    """

    @test fis isa SugenoFuzzySystem{ProdAnd, ProbSumOr}

    @test fis.outputs[:output].mfs == Dictionary([:line1, :line2],
                     [
                         LinearSugenoOutput(Dictionary([:input], [-1.0]), -1.0),
                         ConstantSugenoOutput(0.5),
                     ])

    @test fis.rules == [
        WeightedFuzzyRule(FuzzyRelation(:input, :low), [FuzzyRelation(:output, :line1)],
                          0.5),
        WeightedFuzzyRule(FuzzyRelation(:input, :high), [FuzzyRelation(:output, :line2)],
                          0.5),
    ]
end
