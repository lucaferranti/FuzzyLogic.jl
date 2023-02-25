module MatlabParser

using Dictionaries
using ..FuzzyLogic
using ..FuzzyLogic: FuzzyAnd, FuzzyOr, FuzzyRule, FuzzyRelation, FuzzyNegation, Domain,
                    Variable, memberships, AbstractMembershipFunction

export parse_matlabfis, @matlabfis_str

const MATLAB_JULIA = Dict("'mamdani'" => MamdaniFuzzySystem,
                          "'sugeno'" => SugenoFuzzySystem,
                          "and'min'" => MinAnd(), "and'prod'" => ProdAnd(),
                          "or'max'" => MaxOr(), "or'probor'" => ProbSumOr(),
                          "imp'min'" => MinImplication(), "imp'prod'" => ProdImplication(),
                          "agg'max'" => MaxAggregator(),
                          "agg'probor'" => ProbSumAggregator(),
                          "'centroid'" => CentroidDefuzzifier(),
                          "'bisector'" => BisectorDefuzzifier(),
                          "'trapmf'" => TrapezoidalMF,
                          "'trimf'" => TriangularMF,
                          "'gaussmf'" => GaussianMF,
                          "'gbellmf'" => GeneralizedBellMF,
                          "'sigmf'" => SigmoidMF,
                          "'dsigmf'" => DifferenceSigmoidMF,
                          "'psigmf'" => ProductSigmoidMF,
                          "'zmf'" => ZShapeMF,
                          "'smf'" => SShapeMF,
                          "'pimf'" => PiShapeMF,
                          "'linzmf'" => LinearMF,
                          "'linsmf'" => LinearMF,
                          "'constant'" => ConstantSugenoOutput,
                          "'linear'" => LinearSugenoOutput)

# Handle special cases where FuzzyLogic.jl and matlab dont store parameters the same way.
function preprocess_params(mftype, mfparams; inputs = nothing)
    mftype in ("'gaussmf'", "'linzmf'") && return reverse(mfparams)
    mftype == "'linear'" &&
        return [Dictionary(inputs, mfparams[1:(end - 1)]), mfparams[end]]
    mfparams
end

function parse_mf(line::AbstractString; inputs = nothing)
    mfname, mftype, mfparams = split(line, r"[:,]")
    mfname = Symbol(mfname[2:(end - 1)])
    mfparams = parse.(Float64, split(mfparams[2:(end - 1)]))
    mfparams = preprocess_params(mftype, mfparams; inputs)
    mfname, MATLAB_JULIA[mftype](mfparams...)
end

function parse_var(var; inputs = nothing)
    dom = Domain(parse.(Float64, split(var["Range"][2:(end - 1)]))...)
    name = Symbol(var["Name"][2:(end - 1)])
    mfs = map(1:parse(Int, var["NumMFs"])) do i
        mfname, mf = parse_mf(var["MF$i"]; inputs)
        mfname => mf
    end |> dictionary
    name, Variable(dom, mfs)
end

function parse_rule(line, inputnames, outputnames, inputmfs, outputmfs)
    ants, cons, op = split(line, r"[,:] ")
    antsidx = filter!(!iszero, parse.(Int, split(ants)))
    considx = filter!(!iszero, parse.(Int, split(cons)[1:length(outputnames)]))
    # TODO: weighted rules
    op = op == "1" ? FuzzyAnd : FuzzyOr
    length(antsidx) == 1 && (op = identity)
    ant = mapreduce(op, enumerate(antsidx)) do (var, mf)
        if mf > 0
            FuzzyRelation(inputnames[var], inputmfs[var][mf])
        else
            FuzzyNegation(inputnames[var], inputmfs[var][-mf])
        end
    end
    con = map(enumerate(considx)) do (var, mf)
        FuzzyRelation(outputnames[var], outputmfs[var][mf])
    end
    FuzzyRule(ant, con)
end

function parse_rules(lines, inputs, outputs)
    inputnames = collect(keys(inputs))
    outputnames = collect(keys(outputs))
    inputmfs = collect.(keys.(memberships.(collect(inputs))))
    outputmfs = collect.(keys.(memberships.(collect(outputs))))
    FuzzyRule[parse_rule(line, inputnames, outputnames, inputmfs, outputmfs)
              for line in lines]
end

"""
    parse_matlabfis(s::AbstractString)

Parse a fuzzy inference system from a string in Matlab FIS format.
"""
function parse_matlabfis(s::AbstractString)
    lines = strip.(split(s, "\n"))
    key = ""
    fis = Dict()
    for line in lines
        if occursin(r"\[[a-zA-Z0-9_]+\]", line)
            key = line
            fis[key] = ifelse(key == "[Rules]", [], Dict())
        elseif !isempty(line)
            if key != "[Rules]"
                k, v = split(line, "=")
                fis[key][k] = v
            else
                push!(fis[key], line)
            end
        end
    end
    sysinfo = fis["[System]"]
    inputs = Dictionary{Symbol, Variable}()
    for i in 1:parse(Int, sysinfo["NumInputs"])
        varname, var = parse_var(fis["[Input$i]"])
        insert!(inputs, varname, var)
    end
    outputs = Dictionary{Symbol, Variable}()
    for i in 1:parse(Int, sysinfo["NumOutputs"])
        varname, var = parse_var(fis["[Output$i]"]; inputs = collect(keys(inputs)))
        insert!(outputs, varname, var)
    end
    rules = parse_rules(fis["[Rules]"], inputs, outputs)
    opts = (; name = Symbol(sysinfo["Name"][2:(end - 1)]), inputs = inputs,
            outputs = outputs, rules = rules,
            and = MATLAB_JULIA["and" * sysinfo["AndMethod"]],
            or = MATLAB_JULIA["or" * sysinfo["OrMethod"]])

    if sysinfo["Type"] == "'mamdani'"
        opts = (; opts..., implication = MATLAB_JULIA["imp" * sysinfo["ImpMethod"]],
                aggregator = MATLAB_JULIA["agg" * sysinfo["AggMethod"]],
                defuzzifier = MATLAB_JULIA[sysinfo["DefuzzMethod"]])
    end

    MATLAB_JULIA[sysinfo["Type"]](; opts...)
end

"""
String macro to parse Matlab fis formats. See [`parse_matlabfis`](@ref) for more details.
"""
macro matlabfis_str(s::AbstractString)
    parse_matlabfis(s)
end

end
