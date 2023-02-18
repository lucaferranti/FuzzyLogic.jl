
module FCLParser

using PEG, Dictionaries
using ..FuzzyLogic
using ..FuzzyLogic: Variable, Domain

export parse_fcl

const FCL_JULIA = Dict("COG" => CentroidDefuzzifier(),
                       "COGS" => "COGS", # dummy since hardcoded for sugeno
                       "COA" => BisectorDefuzzifier(),
                       "ANDMIN" => MinAnd(),
                       "ANDPROD" => ProdAnd(),
                       "ANDBDIF" => LukasiewiczAnd(),
                       "ORMAX" => MaxOr(),
                       "ORASUM" => ProbSumOr(),
                       "ORBSUM" => BoundedSumOr(),
                       "ACTPROD" => ProdImplication(),
                       "ACTMIN" => MinImplication())

function fcl_julia(s::AbstractString)
    haskey(FCL_JULIA, s) ? FCL_JULIA[s] : throw(ArgumentError("Option $s not supported."))
end

@rule id = r"[a-zA-Z_]+[a-zA-z0-9_]*"p |> Symbol
@rule function_block = r"FUNCTION_BLOCK"p & id & var_input_block & var_output_block &
                       fuzzify_block[1:end] & defuzzify_block[1:end] & rule_block &
                       r"END_FUNCTION_BLOCK"p |> x -> x[2:7]

@rule var_input_block = r"VAR_INPUT"p & var_def[1:end] & r"END_VAR"p |>
                        x -> Vector{Symbol}(x[2])
@rule var_output_block = r"VAR_OUTPUT"p & var_def[1:end] & r"END_VAR"p |>
                         x -> Vector{Symbol}(x[2])
@rule var_def = id & r":"p & r"REAL"p & r";"p |> first

@rule fuzzify_block = r"FUZZIFY"p & id & linguistic_term[1:end] & range_term &
                      r"END_FUZZIFY"p |> x -> x[2] => Variable(x[4], dictionary(x[3]))

@rule range_term = r"RANGE\s*:=\s*\("p & numeral & r".."p & numeral & r"\)\s*;"p |>
                   x -> Domain(x[2], x[4])

@rule linguistic_term = r"TERM"p & id & r":="p & membership_function & r";"p |>
                        x -> x[2] => x[4]
@rule membership_function = singleton, points
@rule singleton = r"[+-]?\d+\.?\d*([eE][+-]?\d+)?"p |>
                  ConstantSugenoOutput ∘ Base.Fix1(parse, Float64)

@rule numeral = r"[+-]?\d+(\.\d+)?([eE][+-]?\d+)?"p |> Base.Fix1(parse, Float64)
@rule point = r"\("p & numeral & r","p & numeral & r"\)"p |> x -> tuple(x[2], x[4])
@rule points = point[2:end] |> PiecewiseLinearMF ∘ Vector{Tuple{Float64, Float64}}

@rule defuzzify_block = r"DEFUZZIFY"p & id & linguistic_term[1:end] & defuzzify_method &
                        range_term & r"END_DEFUZZIFY"p |>
                        (x -> (x[2] => Variable(x[5], dictionary(x[3])), x[4]))

@rule defuzzify_method = r"METHOD\s*:"p & (r"COGS"p, r"COG"p, r"COA"p, r"LM"p, r"RM"p) &
                         r";"p |> x -> fcl_julia(x[2])

@rule rule_block = r"RULEBLOCK"p & id & operator_definition & activation_method[:?] &
                   rule[1:end] & r"END_RULEBLOCK"p |>
                   x -> (x[3], x[4], Vector{FuzzyLogic.FuzzyRule}(x[5]))

@rule or_definition = r"OR"p & r":"p & (r"MAX"p, r"ASUM"p, r"BSUM"p) & r";"p
@rule and_definition = r"AND"p & r":"p & (r"MIN"p, r"PROD"p, r"BDIF"p) & r";"p
@rule operator_definition = (and_definition, or_definition) |>
                            x -> fcl_julia(join([x[1], x[3]]))
@rule activation_method = r"ACT"p & r":"p & (r"MIN"p, r"PROD"p) & r";"p |>
                          x -> fcl_julia(join([x[1], x[3]]))

@rule rule = r"RULE\s+\d+\s*:\s*IF"p & condition & r"THEN"p & conclusion & r";"p |>
             x -> FuzzyLogic.FuzzyRule(x[2], x[4])
@rule relation = posrel, negrel
@rule posrel = id & r"IS"p & id |> x -> FuzzyLogic.FuzzyRelation(x[1], x[3])
@rule negrel = (id & r"IS\s+NOT"p & id |> x -> FuzzyLogic.FuzzyNegation(x[1], x[3])),
               r"NOT\s*\("p & id & r"IS"p & id & r"\)"p |>
               x -> FuzzyLogic.FuzzyNegation(x[2], x[4])
@rule conclusion = posrel & (r","p & posrel)[*] |> x -> append!([x[1]], map(last, x[2]))

@rule condition = andcondition, orcondition
@rule andcondition = relation & (r"AND"p & relation)[*] |>
                     x -> reduce(FuzzyLogic.FuzzyAnd, append!([x[1]], map(last, x[2])))
@rule orcondition = relation & (r"OR"p & relation)[*] |>
                    x -> reduce(FuzzyLogic.FuzzyOr, append!([x[1]], map(last, x[2])))

function parse_fcl(s::String)
    name, inputs, outputs, inputsmfs, outputsmf, (op, imp, rules) = parse_whole(function_block,
                                                                                s)
    varsin = dictionary(inputsmfs)
    @assert sort(collect(keys(varsin)))==sort(inputs) "Mismatch between declared and fuzzified input variables."

    varsout = dictionary(first.(outputsmf))
    @assert sort(collect(keys(varsout)))==sort(outputs) "Mismatch between declared and defuzzified output variables."

    @assert allequal(last.(outputsmf)) "All output variables should use the same defuzzification method."
    defuzzifier = outputsmf[1][2]
    and, or = ops_pairs(op)
    if defuzzifier == "COGS" # sugeno
        SugenoFuzzySystem(name, varsin, varsout, rules, and, or)
    else # mamdani
        imp = isempty(imp) ? MinImplication() : first(imp)
        MamdaniFuzzySystem(name, varsin, varsout, rules, and, or, imp, MaxAggregator(),
                           defuzzifier)
    end
end

ops_pairs(::MinAnd) = MinAnd(), MaxOr()
ops_pairs(::ProdAnd) = ProdAnd(), ProbSumOr()
ops_pairs(::LukasiewiczAnd) = LukasiewiczAnd(), BoundedSumOr()
ops_pairs(::MaxOr) = MinAnd(), MaxOr()
ops_pairs(::ProbSumOr) = ProdAnd(), ProbSumOr()
ops_pairs(::BoundedSumOr) = LukasiewiczAnd(), BoundedSumOr()

end
