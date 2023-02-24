"""
Read a fuzzy system from a file using a specified format.

### Inputs

- `file::String` -- path to the file to read.
- `fmt::Union{Symbol,Nothing}` -- input format of the file. If `nothing`, it is inferred from the file extension.

Supported formats are

- `:fcl` (corresponding file extension `.fcl`)
"""
function readfis(file::String, fmt::Union{Symbol, Nothing} = nothing)::AbstractFuzzySystem
    if isnothing(fmt)
        ex = split(file, ".")[end]
        fmt = if ex == "fcl"
            :fcl
        elseif ex == "fis"
            :matlab
        else
            throw(ArgumentError("Unrecognized extension $ex."))
        end
    end

    s = read(file, String)
    if fmt === :fcl
        parse_fcl(s)
    elseif fmt === :matlab
        parse_matlabfis(s)
    else
        throw(ArgumentError("Unknown format $fmt."))
    end
end
