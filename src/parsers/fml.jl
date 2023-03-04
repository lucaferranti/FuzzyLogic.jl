module FMLParser

using Dictionaries, LightXML
using ..FuzzyLogic
using ..FuzzyLogic: FuzzyAnd, FuzzyOr, FuzzyRule, FuzzyRelation, FuzzyNegation, Domain,
                    WeightedFuzzyRule, Variable, memberships, AbstractMembershipFunction,
                    AbstractSugenoOutputFunction

export parse_fml, @fml_str

XML_JULIA = Dict("mamdaniRuleBase" => MamdaniFuzzySystem,
                 "tskRuleBase" => SugenoFuzzySystem,
                 "triangularShape" => TriangularMF,
                 "trapezoidShape" => TrapezoidalMF,
                 "piShape" => PiShapeMF,
                 "sShape" => SShapeMF,
                 "zShape" => ZShapeMF,
                 "gaussianShape" => GaussianMF,
                 "rightGaussianShape" => GaussianMF,
                 "leftGaussianShape" => GaussianMF,
                 "rightLinearShape" => LinearMF,
                 "leftLinearShape" => LinearMF,
                 "rightLinearShape" => LinearMF,
                 "COG" => CentroidDefuzzifier(),
                 "COA" => BisectorDefuzzifier(),
                 "ACCMAX" => MaxAggregator(),
                 "andMIN" => MinAnd(),
                 "andPROD" => ProdAnd(),
                 "andBDIF" => LukasiewiczAnd(),
                 "andDRP" => DrasticAnd(),
                 "andHPROD" => HamacherAnd(),
                 "andEPROD" => EinsteinAnd(),
                 "andNILMIN" => DrasticAnd(),
                 "orMAX" => MaxOr(),
                 "orPROBOR" => ProbSumOr(),
                 "orBSUM" => BoundedSumOr(),
                 "orDRS" => DrasticOr(),
                 "orNILMAX" => NilpotentOr(),
                 "orESUM" => EinsteinOr(),
                 "orHSUM" => HamacherOr(),
                 "impMIN" => MinImplication(),
                 "and" => FuzzyAnd,
                 "or" => FuzzyOr)

get_attribute(x, s, d) = has_attribute(x, s) ? attribute(x, s) : d
to_key(s, pre) = isempty(pre) ? s : pre * uppercasefirst(s)

function process_params(mf, params)
    if mf == "rightLinearShape"
        reverse(params)
    else
        params
    end
end

# Parse variable from xml. FML does not have negated relations, but negated mfs,
# so we store in the set `negated` what relations will have to be `FuzzyNegation`.
function parse_variable!(var, negated::Set)
    varname = Symbol(attribute(var, "name"))
    dom = Domain(parse(Float64, attribute(var, "domainleft")),
                 parse(Float64, attribute(var, "domainright")))
    mfs = AbstractMembershipFunction[]
    mfnames = Symbol[]
    for term in get_elements_by_tagname(var, "fuzzyTerm")
        mfname = Symbol(attribute(term, "name"))
        push!(mfnames, mfname)
        if has_attribute(term, "complement") &&
           lowercase(attribute(term, "complement")) == "true"
            push!(negated, (varname, mfname))
        end
        mf = only(child_elements(term))
        params = process_params(name(mf), parse.(Float64, value.(collect(attributes(mf)))))
        push!(mfs, XML_JULIA[name(mf)](params...))
    end
    return varname => Variable(dom, Dictionary(mfnames, identity.(mfs)))
end

function parse_sugeno_output(var, input_names)
    varname = Symbol(attribute(var, "name"))
    dom = Domain(parse(Float64, get_attribute(var, "domainleft", "-Inf")),
                 parse(Float64, get_attribute(var, "domainright", "Inf")))
    mfs = AbstractSugenoOutputFunction[]
    mfnames = Symbol[]
    for term in get_elements_by_tagname(var, "tskTerm")
        push!(mfnames, Symbol(attribute(term, "name")))
        mf = if attribute(term, "order") == "0"
            ConstantSugenoOutput(parse(Float64, content(find_element(term, "tskValue"))))
        elseif attribute(term, "order") == "1"
            coeffs = map(get_elements_by_tagname(term, "tskValue")) do t
                parse(Float64, content(t))
            end
            LinearSugenoOutput(Dictionary(input_names, coeffs[1:(end - 1)]), coeffs[end])
        end
        push!(mfs, mf)
    end
    return varname => Variable(dom, Dictionary(mfnames, identity.(mfs)))
end

function parse_knowledgebase(kb, settings)
    negated = Set{Tuple{Symbol, Symbol}}()
    inputs = Pair{Symbol, Variable}[]
    outputs = Pair{Symbol, Variable}[]
    for var in get_elements_by_tagname(kb, "fuzzyVariable")
        if attribute(var, "type") == "input"
            push!(inputs, parse_variable!(var, negated))
        elseif attribute(var, "type") == "output"
            settings[:defuzzifier] = XML_JULIA[get_attribute(var, "defuzzifier", "COG")]
            settings[:aggregator] = XML_JULIA["ACC" * get_attribute(var, "accumulation",
                                                                    "MAX")]
            push!(outputs, parse_variable!(var, negated))
        end
    end

    for var in get_elements_by_tagname(kb, "tskVariable")
        push!(outputs, parse_sugeno_output(var, first.(inputs)))
    end
    settings[:inputs] = dictionary(identity.(inputs))
    settings[:outputs] = dictionary(identity.(outputs))
    return negated
end

function parse_rules!(settings, rulebase, negated)
    pre = name(rulebase) == "tskRuleBase" ? "tsk" : ""
    settings[:and] = XML_JULIA["and" * get_attribute(rulebase, "andMethod", "MIN")]
    settings[:or] = XML_JULIA["or" * get_attribute(rulebase, "orMethod", "MAX")]

    if isempty(pre)
        settings[:implication] = XML_JULIA["imp" * get_attribute(rulebase,
                                                                 "activationMethod",
                                                                 "MIN")]
    end

    settings[:rules] = identity.([parse_rule(rule, negated, pre)
                                  for rule in get_elements_by_tagname(rulebase,
                                                                      to_key("rule", pre))])
end

function parse_rule(rule, negated, pre = "")
    op = XML_JULIA[lowercase(get_attribute(rule, "connector", "and"))]

    ant = find_element(rule, "antecedent")
    ant = mapreduce(op, get_elements_by_tagname(ant, "clause")) do clause
        var = Symbol(content(find_element(clause, "variable")))
        t = Symbol(content(find_element(clause, "term")))
        (var, t) in negated ? FuzzyNegation(var, t) : FuzzyRelation(var, t)
    end

    cons = find_element(find_element(rule, to_key("consequent", pre)), to_key("then", pre))
    cons = map(get_elements_by_tagname(cons, to_key("clause", pre))) do clause
        var = Symbol(content(find_element(clause, "variable")))
        t = Symbol(content(find_element(clause, "term")))
        (var, t) in negated ? FuzzyNegation(var, t) : FuzzyRelation(var, t)
    end

    w = parse(Float64, get_attribute(rule, "weight", "1.0"))
    if isone(w)
        FuzzyRule(ant, cons)
    else
        WeightedFuzzyRule(ant, cons, w)
    end
end

function get_rulebase(f)
    rules = find_element(f, "mamdaniRuleBase")
    isnothing(rules) || return rules
    rules = find_element(f, "tskRuleBase")
    isnothing(rules) || return rules
end

"""
    parse_fml(s::String)::AbstractFuzzySystem

Parse a fuzzy inference system from a string representation in Fuzzy Markup Language (FML).

### Inputs

- `s::String` -- string describing a fuzzy system in FML conformant to the IEEE 1855-2016 standard.

### Notes

The parsers can read FML comformant to IEEE 1855-2016, with the following remarks:

- only Mamdani and Sugeno are supported.
- Operators `and` and `or` definitions should be set in the rule base block.
  Definitions at individual rules are ignored.
- Modifiers are not supported.
"""
function parse_fml(s::String)
    parse_fml(root(parse_string(s)))
end

function parse_fml(f::XMLElement)
    settings = Dict()
    kb = only(get_elements_by_tagname(f, "knowledgeBase"))
    settings[:name] = Symbol(attribute(f, "name"))
    negated = parse_knowledgebase(kb, settings)
    rulebase = get_rulebase(f)
    parse_rules!(settings, rulebase, negated)
    settings

    XML_JULIA[name(rulebase)](; settings...)
end

"""
String macro to parse Fuzzy Markup Language (FML). See [`parse_fml`](@ref) for more details.
"""
macro fml_str(s)
    parse_fml(s)
end

end
