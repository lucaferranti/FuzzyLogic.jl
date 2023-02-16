using PEG, Dictionaries

@rule id = r"[a-zA-Z_]+[a-zA-z0-9_]*"p |> Symbol
@rule function_block = r"FUNCTION_BLOCK"p & id & fuzzify_block[1:end] &
                       r"END_FUNCTION_BLOCK"p |> x -> x[2:3]

@rule fuzzify_block = r"FUZZIFY"p & id & linguistic_term[1:end] & r"END_FUZZIFY"p |>
                      x -> x[2] => dictionary(x[3])

@rule linguistic_term = r"TERM"p & id & r":="p & membership_function & r";"p |>
                        x -> x[2] => x[4]
@rule membership_function = numeral, points
@rule numeral = r"[+-]?\d+\.?\d*([eE][+-]?\d+)?" |> Base.Fix1(parse, Float64)
@rule point = r"\("p & numeral & r","p & numeral & r"\)"p |> x -> tuple(x[2], x[4])
@rule points = point[2:end]

s = """
FUNCTION_BLOCK tipper

FUZZIFY temp
TERM cold := (3, 1) (27, 0);
TERM hot := (3, 0) (27, 1);
END_FUZZIFY

FUZZIFY pressure
  TERM low := (55, 1) (95, 0);
  TERM high:= (55, 0) (95, 1);
END_FUZZIFY

END_FUNCTION_BLOCK
"""
