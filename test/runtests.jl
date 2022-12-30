using SafeTestsets, Test

testfiles = [
    "test_membership_functions.jl",
    "test_parser.jl",
    "test_aqua.jl",
    "test_doctests.jl",
]

for file in testfiles
    @eval @time @safetestset $file begin include($file) end
end
