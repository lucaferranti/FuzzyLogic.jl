struct Interval{T <: Real}
    lo::T
    hi::T
end

inf(a::Interval) = a.lo
sup(a::Interval) = a.hi
inf(a::Real) = a
sup(a::Real) = a
mid(a::Interval) = (a.lo + a.hi) / 2
mid(a::Real) = a
diam(a::Interval) = a.hi - a.lo
diam(x::Real) = zero(x)

Base.convert(::Type{Interval{T}}, x::Real) where {T <: Real} = Interval(T(x), T(x))

Base.float(::Type{Interval{T}}) where {T <: Real} = T

Base.:+(a::Interval) = a
Base.:-(a::Interval) = Interval(-a.hi, -a.lo)
Base.:+(a::Interval, b::Interval) = Interval(a.lo + b.lo, a.hi + b.hi)
Base.:-(a::Interval, b::Interval) = Interval(a.lo - b.hi, a.hi - b.lo)

function Base.:*(a::Interval, b::Interval)
    Interval(extrema((a.lo * b.lo, a.lo * b.hi, a.hi * b.lo, a.hi * b.hi))...)
end

function Base.:/(a::Interval, b::Interval)
    Interval(extrema((a.lo / b.lo, a.lo / b.hi, a.hi / b.lo, a.hi / b.hi))...)
end
Base.min(a::Interval, b::Interval) = Interval(min(a.lo, b.lo), min(a.hi, b.hi))
Base.max(a::Interval, b::Interval) = Interval(max(a.lo, b.lo), max(a.hi, b.hi))
Base.zero(::Type{Interval{T}}) where {T <: Real} = Interval(zero(T), zero(T))

for op in (:+, :-, :*, :/, :min, :max)
    @eval Base.$op(a::Interval, b::Real) = $op(a, Interval(b, b))
    @eval Base.$op(a::Real, b::Interval) = $op(Interval(a, a), b)
end

function Base.:≈(a::Interval, b::Interval; kwargs...)
    ≈(a.lo, b.lo; kwargs...) && ≈(a.hi, b.hi; kwargs...)
end
