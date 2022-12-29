using SafeTestsets, Test

testfiles = ["test_membership_functions.jl"]

for file in testfiles
    @eval @time @safetestset $file begin include($file) end
end
