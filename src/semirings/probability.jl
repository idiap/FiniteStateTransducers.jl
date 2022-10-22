# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export ProbabilityWeight
"""
`ProbabilityWeight(x)`

| Set            |``\\oplus``   |  ``\\otimes``  | ``\\bar{0}`` | ``\\bar{1}`` |
|:--------------:|:------------:|:--------------:|:------------:|:------------:|
|``\\mathbb{R}`` |       +      |        *       |   ``0``      |   ``1``      | 
"""
struct ProbabilityWeight{T <: AbstractFloat} <: Semiring
  x::T
end

zero(::Type{ProbabilityWeight{T}}) where T = ProbabilityWeight{T}(zero(T))
one(::Type{ProbabilityWeight{T}}) where T = ProbabilityWeight{T}(one(T))

*(a::ProbabilityWeight{T}, b::ProbabilityWeight{T}) where {T <: AbstractFloat} = ProbabilityWeight{T}(a.x * b.x)
+(a::ProbabilityWeight{T}, b::ProbabilityWeight{T}) where {T <: AbstractFloat} = ProbabilityWeight{T}(a.x + b.x)
/(a::ProbabilityWeight{T}, b::ProbabilityWeight{T}) where {T <: AbstractFloat} = ProbabilityWeight{T}(a.x / b.x)

# properties
iscommutative(::Type{W}) where {W<:ProbabilityWeight} = true
isleft(::Type{W}) where {W<:ProbabilityWeight} = true
isright(::Type{W}) where {W<:ProbabilityWeight} = true
isweaklydivisible(::Type{W}) where {W <: ProbabilityWeight}= true
iscomplete(::Type{W}) where {W <: ProbabilityWeight} = true
