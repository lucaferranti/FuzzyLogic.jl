using Dictionaries, FuzzyLogic, PEG, Test
using FuzzyLogic: Variable, Domain, FuzzyRelation, FuzzyAnd, FuzzyOr, FuzzyNegation,
                  WeightedFuzzyRule, FuzzyRule

@testset "parse Mamdani infernce system" begin
    fis = readfis(joinpath(@__DIR__, "data", "tipper.xml"))

    @test fis isa MamdaniFuzzySystem{MinAnd, MaxOr, MinImplication, MaxAggregator,
                             CentroidDefuzzifier}
    @test fis.name == :tipper

    service = Variable(Domain(0.0, 10.0),
                       Dictionary([:poor, :good, :excellent],
                                  [GaussianMF(0.0, 2.0), GaussianMF(5.0, 2.0),
                                      GaussianMF(10.0, 2.0)]))

    food = Variable(Domain(0.0, 10.0),
                    Dictionary([:rancid, :delicious],
                               [
                                   LinearMF(5.5, 0.0),
                                   LinearMF(5.5, 10.0),
                               ]))

    tip = Variable(Domain(0.0, 20.0),
                   Dictionary([:cheap, :average, :generous],
                              [
                                  TriangularMF(0.0, 5.0, 10.0),
                                  TriangularMF(5.0, 10.0, 15.0),
                                  TriangularMF(10.0, 15.0, 20.0),
                              ]))

    @test fis.inputs == Dictionary([:food, :service], [food, service])
    @test fis.outputs == Dictionary([:tip], [tip])

    @test fis.rules ==
          [
        FuzzyRule(FuzzyOr(FuzzyRelation(:food, :rancid), FuzzyRelation(:service, :poor)),
                  [FuzzyRelation(:tip, :cheap)]),
        FuzzyRule(FuzzyRelation(:service, :good), [FuzzyRelation(:tip, :average)]),
        FuzzyRule(FuzzyOr(FuzzyRelation(:service, :excellent),
                          FuzzyRelation(:food, :delicious)),
                  [FuzzyRelation(:tip, :generous)]),
    ]
end

@testset "Test Sugeno inference system" begin
    fis = fml"""
    <?xml version="1.0" encoding="UTF-8"?>
    <fuzzySystem name="tipper" networkAddress="127.0.0.1">
        <knowledgeBase>
            <fuzzyVariable name="food" domainleft="0.0" domainright="10.0" scale=""
                type="input">
            <fuzzyTerm name="rancid" complement="false">
                <rightLinearShape param1="0.0" param2="5.5" />
            </fuzzyTerm>
            <fuzzyTerm name="rancid2" complement="true">
                <rightLinearShape param1="0.0" param2="5.5" />
            </fuzzyTerm>
            <fuzzyTerm name="delicious" complement="false">
                <leftLinearShape param1="5.5" param2="10.0" />
            </fuzzyTerm>
            </fuzzyVariable>
            <fuzzyVariable name="service" domainleft="0.0" domainright="10.0" scale=""
                type="input">
            <fuzzyTerm name="poor" complement="false">
                <rightGaussianShape param1="0.0" param2="2.0" />
            </fuzzyTerm>
            <fuzzyTerm name="good" complement="false">
                <gaussianShape param1="5.0" param2="2.0" />
            </fuzzyTerm>
            <fuzzyTerm name="excellent" complement="false">
                <leftGaussianShape param1="10.0" param2="2.0" />
            </fuzzyTerm>
            </fuzzyVariable>
            <tskVariable name="tip" scale="null" combination="WA" type="output">
                <tskTerm name="average" order="0">
                    <tskValue>1.6</tskValue>
                </tskTerm>
                <tskTerm name="cheap" order="1">
                    <tskValue>1.9</tskValue>
                    <tskValue>5.6</tskValue>
                    <tskValue>6.0</tskValue>
                </tskTerm>
                <tskTerm name="generous" order="1">
                    <tskValue>0.6</tskValue>
                    <tskValue>1.3</tskValue>
                    <tskValue>1.0</tskValue>
                </tskTerm>
            </tskVariable>
        </knowledgeBase>
        <tskRuleBase name="No1" andMethod="PROD" orMethod="PROBOR">
            <tskRule name="reg1" connector="or" orMethod="MAX" weight="1.0">
                <antecedent>
                    <clause>
                        <variable>food</variable>
                        <term>rancid</term>
                    </clause>
                    <clause>
                        <variable>service</variable>
                        <term>poor</term>
                    </clause>
                </antecedent>
                <tskConsequent>
                    <tskThen>
                        <tskClause>
                            <variable>tip</variable>
                            <term>cheap</term>
                        </tskClause>
                    </tskThen>
                </tskConsequent>
            </tskRule>
            <tskRule name="reg2" connector="and" weight="0.75">
                <antecedent>
                    <clause>
                        <variable>service</variable>
                        <term>good</term>
                    </clause>
                    <clause>
                        <variable>food</variable>
                        <term>rancid2</term>
                    </clause>
                </antecedent>
                <tskConsequent>
                    <tskThen>
                        <tskClause>
                            <variable>tip</variable>
                            <term>average</term>
                        </tskClause>
                    </tskThen>
                </tskConsequent>
            </tskRule>
            <tskRule name="reg3" connector="or" orMethod="MAX" weight="1.0">
                <antecedent>
                    <clause>
                        <variable>food</variable>
                        <term>delicious</term>
                    </clause>
                    <clause>
                        <variable>service</variable>
                        <term>excellent</term>
                    </clause>
                </antecedent>
                <tskConsequent>
                    <tskThen>
                        <tskClause>
                            <variable>tip</variable>
                            <term>generous</term>
                        </tskClause>
                    </tskThen>
                </tskConsequent>
            </tskRule>
        </tskRuleBase>
    </fuzzySystem>
    """

    @test fis isa SugenoFuzzySystem{ProdAnd, ProbSumOr}

    @test fis.outputs[:tip] == Variable(Domain(-Inf, Inf),
                   Dictionary([:average, :cheap, :generous],
                              [
                                  ConstantSugenoOutput(1.6),
                                  LinearSugenoOutput(Dictionary([:food, :service],
                                                                [1.9, 5.6]), 6.0),
                                  LinearSugenoOutput(Dictionary([:food, :service],
                                                                [0.6, 1.3]), 1.0),
                              ]))

    @test fis.rules ==
          [
        FuzzyRule(FuzzyOr(FuzzyRelation(:food, :rancid), FuzzyRelation(:service, :poor)),
                  [FuzzyRelation(:tip, :cheap)]),
        WeightedFuzzyRule(FuzzyAnd(FuzzyRelation(:service, :good),
                                   FuzzyNegation(:food, :rancid2)),
                          [FuzzyRelation(:tip, :average)], 0.75),
        FuzzyRule(FuzzyOr(FuzzyRelation(:food, :delicious),
                          FuzzyRelation(:service, :excellent)),
                  [FuzzyRelation(:tip, :generous)]),
    ]
end
