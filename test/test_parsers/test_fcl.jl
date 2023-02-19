using Dictionaries, FuzzyLogic, PEG, Test
using FuzzyLogic: Variable, Domain, FuzzyRelation, FuzzyAnd, FuzzyOr, FuzzyNegation,
                  FuzzyRule

@testset "parse propositions" begin
    s = [
        "a IS b OR Ix IS black AND th IS NOT red",
        "(a IS b OR Ix IS black) AND th IS NOT red",
        "a IS ai AND (b IS bi OR NOT (c IS ci))",
    ]
    r = [
        FuzzyOr(FuzzyRelation(:a, :b),
                FuzzyAnd(FuzzyRelation(:Ix, :black), FuzzyNegation(:th, :red))),
        FuzzyAnd(FuzzyOr(FuzzyRelation(:a, :b), FuzzyRelation(:Ix, :black)),
                 FuzzyNegation(:th, :red)),
        FuzzyAnd(FuzzyRelation(:a, :ai),
                 FuzzyOr(FuzzyRelation(:b, :bi), FuzzyNegation(:c, :ci))),
    ]
    for (si, ri) in zip(s, r)
        @test parse_whole(FuzzyLogic.FCLParser.condition, si) == ri
    end
end

@testset "Parse Sugeno FIS from FCL" begin
    fis1 = fcl"""
    FUNCTION_BLOCK container_crane

    VAR_INPUT
      distance: REAL;
      angle: REAL;
    END_VAR

    VAR_OUTPUT
      power: REAL;
    END_VAR

    FUZZIFY distance
      TERM too_far:= (-5, 1) ( 0, 0);
      TERM zero := (-5, 0) ( 0, 1) ( 5,0);
      TERM close := ( 0, 0) ( 5, 1) (10,0);
      TERM medium := ( 5, 0) (10, 1) (22,0);
      TERM far := (10, 0) (22,1);
      RANGE := (-7 .. 23);
    END_FUZZIFY

    FUZZIFY angle
      TERM neg_big := (-50, 1) (-5, 0);
      TERM neg_small := (-50, 0) (-5, 1) ( 0,0);
      TERM zero := ( -5, 0) ( 0, 1) ( 5,0);
      TERM pos_small := ( 0, 0) ( 5, 1) (50,0);
      TERM pos_big   := ( 5, 0) (50, 1);
      RANGE := (-50..50);
    END_FUZZIFY

    DEFUZZIFY power
      TERM neg_high := -27;
      TERM neg_medium := -12;
      TERM zero := 0;
      TERM pos_medium := 12;
      TERM pos_high := 27;
      METHOD : COGS;
      RANGE := (-27..27);
    END_DEFUZZIFY

    RULEBLOCK No1
    AND: MIN;
    RULE 1: IF distance IS far AND angle IS zero THEN power IS pos_medium;
    RULE 2: IF distance IS far AND angle IS neg_small THEN power IS pos_big;
    RULE 3: IF distance IS far AND angle IS neg_big THEN power IS pos_medium;
    RULE 4: IF distance IS medium AND angle IS neg_small THEN power IS neg_medium;
    RULE 5: IF distance IS close AND angle IS pos_small THEN power IS pos_medium;
    RULE 6: IF distance IS zero AND angle IS zero THEN power IS zero;
    END_RULEBLOCK

    END_FUNCTION_BLOCK
    """

    fis2 = readfis(joinpath(@__DIR__, "data", "container_crane.fcl"))

    for fis in (fis1, fis2)
        @test fis isa SugenoFuzzySystem{MinAnd, MaxOr}
        mfs_dist = Dictionary([:too_far, :zero, :close, :medium, :far],
                              [
                                  PiecewiseLinearMF([(-5.0, 1.0), (0.0, 0.0)]),
                                  PiecewiseLinearMF([(-5.0, 0.0), (0.0, 1.0), (5.0, 0.0)]),
                                  PiecewiseLinearMF([(0.0, 0.0), (5.0, 1.0), (10.0, 0.0)]),
                                  PiecewiseLinearMF([(5.0, 0.0), (10.0, 1.0), (22.0, 0.0)]),
                                  PiecewiseLinearMF([(10.0, 0.0), (22.0, 1.0)]),
                              ])
        @test fis.inputs[:distance] == Variable(Domain(-7.0, 23.0), mfs_dist)

        mfs_power = Dictionary([:neg_high, :neg_medium, :zero, :pos_medium, :pos_high],
                               [
                                   ConstantSugenoOutput(-27.0),
                                   ConstantSugenoOutput(-12.0),
                                   ConstantSugenoOutput(0.0),
                                   ConstantSugenoOutput(12.0),
                                   ConstantSugenoOutput(27.0)])
        @test fis.outputs[:power] == Variable(Domain(-27.0, 27.0), mfs_power)

        _parse_rule(exs::Tuple) = eval(FuzzyLogic.parse_rule(exs...))

        rules = [(:(distance == far && angle == zero), [:(power == pos_medium)]),
            (:(distance == far && angle == neg_small), [:(power == pos_big)]),
            (:(distance == far && angle == neg_big), [:(power == pos_medium)]),
            (:(distance == medium && angle == neg_small), [:(power == neg_medium)]),
            (:(distance == close && angle == pos_small), [:(power == pos_medium)]),
            (:(distance == zero && angle == zero), [:(power == zero)]),
        ]
        @test fis.rules == map(_parse_rule, rules)
    end
end

@testset "parse Mamdani system" begin
    fis = fcl"""
    FUNCTION_BLOCK edge_detector

    VAR_INPUT
      Ix: REAL;
      Iy: REAL;
    END_VAR

    VAR_OUTPUT
      Iout: REAL;
    END_VAR

    FUZZIFY Ix
      TERM zero := (-0.3, 0.0) (0.0, 1.0) (0.3, 0.0);
      RANGE := (-1..1);
    END_FUZZIFY

    FUZZIFY Iy
      TERM zero := (-0.3, 0.0) (0.0, 1.0) (0.3, 0.0);
      RANGE := (-1..1);
    END_FUZZIFY

    DEFUZZIFY Iout
      TERM black := (0.0, 1.0) (0.7, 0.0);
      TERM white := (0.1, 0.0) (1.0, 1.0);
      METHOD: COA;
      RANGE := (0.0..1.0);
    END_DEFUZZIFY

    RULEBLOCK rules
      OR: ASUM;
      ACT: PROD;
      RULE 1: IF Ix IS zero AND Iy IS zero THEN Iout IS white;
      RULE 2: IF Ix IS NOT zero OR Iy IS NOT zero THEN Iout IS black;
    END_RULEBLOCK

    END_FUNCTION_BLOCK
    """

    @test fis isa MamdaniFuzzySystem{ProdAnd, ProbSumOr, ProdImplication, MaxAggregator,
                             BisectorDefuzzifier}

    @test fis.inputs[:Ix] == fis.inputs[:Iy] ==
          Variable(Domain(-1.0, 1.0),
                   Dictionary([:zero],
                              [PiecewiseLinearMF([(-0.3, 0.0), (0.0, 1.0), (0.3, 0.0)])]))

    @test fis.outputs[:Iout] == Variable(Domain(0.0, 1.0),
                   Dictionary([:black, :white],
                              [
                                  PiecewiseLinearMF([(0.0, 1.0), (0.7, 0.0)]),
                                  PiecewiseLinearMF([(0.1, 0.0), (1.0, 1.0)]),
                              ]))

    @test fis.rules == [
        FuzzyRule(FuzzyAnd(FuzzyRelation(:Ix, :zero), FuzzyRelation(:Iy, :zero)),
                  [FuzzyRelation(:Iout, :white)]),
        FuzzyRule(FuzzyOr(FuzzyNegation(:Ix, :zero), FuzzyNegation(:Iy, :zero)),
                  [FuzzyRelation(:Iout, :black)]),
    ]
end
