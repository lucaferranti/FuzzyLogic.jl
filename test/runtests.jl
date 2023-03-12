using SafeTestsets, Test

testfiles = [
    "test_intervals.jl",
    "test_membership_functions.jl",
    "test_settings.jl",
    "test_parser.jl",
    "test_evaluation.jl",
    "test_plotting.jl",
    "test_genfis.jl",
    "test_compilation.jl",
    "test_parsers/test_fcl.jl",
    "test_parsers/test_matlab.jl",
    "test_parsers/test_fml.jl",
    "test_aqua.jl",
    "test_doctests.jl",
]

for file in testfiles
    @eval @time @safetestset $file begin include($file) end
end
