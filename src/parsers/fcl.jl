using PEG, Dictionaries, FuzzyLogic

const FCL_JULIA = Dict("COG" => CentroidDefuzzifier(),
                       "COA" => BisectorDefuzzifier(),
                       "ANDMIN" => MinAnd(),
                       "ANDPROD" => ProdAnd(),
                       "ANDBDIF" => LukasiewiczAnd(),
                       "ORMAX" => MaxOr(),
                       "ORASUM" => ProbSumOr(),
                       "ORBSUM" => BoundedSumOr(),
                       "ACTPROD" => ProdImplication(),
                       "ACTMIN" => MinImplication(),
                       "ACCUMAX" => MaxAggregator())

function fcl_julia(s::AbstractString)
    haskey(FCL_JULIA, s) ? FCL_JULIA[s] : throw(ArgumentError("Option $s not supported."))
end

@rule id = r"[a-zA-Z_]+[a-zA-z0-9_]*"p |> Symbol
@rule function_block = r"FUNCTION_BLOCK"p & id & var_input_block & var_output_block &
                       fuzzify_block[1:end] & defuzzify_block[1:end] &
                       r"END_FUNCTION_BLOCK"p |> x -> x[2:6]

@rule var_input_block = r"VAR_INPUT"p & var_def[1:end] & r"END_VAR"p |> x -> x[2]
@rule var_output_block = r"VAR_OUTPUT"p & var_def[1:end] & r"END_VAR"p |> x -> x[2]
@rule var_def = id & r":"p & r"REAL"p & r";"p |> x -> x[1]

@rule fuzzify_block = r"FUZZIFY"p & id & linguistic_term[1:end] & r"END_FUZZIFY"p |>
                      x -> x[2] => dictionary(x[3])

@rule linguistic_term = r"TERM"p & id & r":="p & membership_function & r";"p |>
                        x -> x[2] => x[4]
@rule membership_function = numeral, points
@rule numeral = r"[+-]?\d+\.?\d*([eE][+-]?\d+)?" |> Base.Fix1(parse, Float64)
@rule point = r"\("p & numeral & r","p & numeral & r"\)"p |> x -> tuple(x[2], x[4])
@rule points = point[2:end] |> PiecewiseLinearMF ∘ Vector{Tuple{Float64, Float64}}

@rule defuzzify_block = r"DEFUZZIFY"p & id & linguistic_term[1:end] & defuzzify_method &
                        r"END_DEFUZZIFY"p |> (x -> (x[2] => dictionary(x[3]), x[4]))
@rule defuzzify_method = r"METHOD\s*:"p & (r"COGS"p, r"COG"p, r"COA"p, r"LM"p, r"RM"p) &
                         r";"p |> x -> fcl_julia(x[2])

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
END_FUZZIFY

FUZZIFY angle
  TERM neg_big := (-50, 1) (-5, 0);
  TERM neg_small := (-50, 0) (-5, 1) ( 0,0);
  TERM zero := ( -5, 0) ( 0, 1) ( 5,0);
  TERM pos_small := ( 0, 0) ( 5, 1) (50,0);
  TERM pos_big   := ( 5, 0) (50, 1);
END_FUZZIFY

DEFUZZIFY power
  TERM neg_high := -27;
  TERM neg_medium := -12;
  TERM zero := 0;
  TERM pos_medium := 12;
  TERM pos_high := 27;
  METHOD : COG;
END_DEFUZZIFY

END_FUNCTION_BLOCK
"""

# RULEBLOCK No1
#   AND : MIN;
#   RULE 1: IF distance IS far AND angle IS zero THEN power IS pos_medium;
#   RULE 2: IF distance IS far AND angle IS neg_small THEN power IS pos_big;
#   RULE 3: IF distance IS far AND angle IS neg_big THEN power IS pos_medium;
#   RULE 4: IF distance IS medium AND angle IS neg_small THEN power IS neg_medium;
#   RULE 5: IF distance IS close AND angle IS pos_small THEN power IS pos_medium;
#   RULE 6: IF distance IS zero AND angle IS zero THEN power IS zero;
# END_RULEBLOCK
