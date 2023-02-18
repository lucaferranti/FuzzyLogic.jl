using Dictionaries, FuzzyLogic, Test
using FuzzyLogic: Variable, Domain, FuzzyRelation, FuzzyAnd, FuzzyRule

@testset "Parse Sugeno FIS from FCL" begin
    s = """
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

    fis = parse_fcl(s)

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
