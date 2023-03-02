struct Interval{T <: Real}
    lo::T
    hi::T
end

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

struct Type2MF{MF1 <: AbstractMembershipFunction, MF2 <: AbstractMembershipFunction} <:
       AbstractMembershipFunction
    lo::MF1
    hi::MF2
end
(mf2::Type2MF)(x) = Interval(mf2.lo(x), mf2.hi(x))

..(mf1::AbstractMembershipFunction, mf2::AbstractMembershipFunction) = Type2MF(mf1, mf2)
