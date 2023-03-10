"""
Read a fuzzy system from a file using a specified format.

### Inputs

- `file::String` -- path to the file to read.
- `fmt::Union{Symbol,Nothing}` -- input format of the file. If `nothing`, it is inferred from the file extension.

Supported formats are

- `:fcl` -- Fuzzy Control Language (corresponding file extension `.fcl`)
- `:fml` -- Fuzzy Markup Language (corresponding file extension `.xml`)
- `:matlab` -- Matlab fis (corresponding file extension `.fis`)
"""
function readfis(file::String, fmt::Union{Symbol, Nothing} = nothing)::AbstractFuzzySystem
    if isnothing(fmt)
        ex = split(file, ".")[end]
        fmt = if ex == "fcl"
            :fcl
        elseif ex == "fis"
            :matlab
        elseif ex == "xml"
            :fml
        else
            throw(ArgumentError("Unrecognized extension $ex."))
        end
    end

    s = read(file, String)
    if fmt === :fcl
        parse_fcl(s)
    elseif fmt === :matlab
        parse_matlabfis(s)
    elseif fmt === :fml
        parse_fml(s)
    else
        throw(ArgumentError("Unknown format $fmt."))
    end
end
