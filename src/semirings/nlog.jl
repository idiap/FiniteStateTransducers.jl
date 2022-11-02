# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export NLogWeight

"""
`NLogWeight(x)`

| Set                                 |     ``\\oplus``         |  ``\\otimes``  | ``\\bar{0}`` | ``\\bar{1}`` |
|:-----------------------------------:|:-----------------------:|:--------------:|:------------:|:------------:|
|``\\mathbb{R}\\cup\\{\\pm\\infty\\}``|``-\\log(e^{-x}+e^{-y})``|     ``+``      |``\\infty``   |   ``0``      | 
"""
struct NLogWeight{T <: AbstractFloat} <: Semiring
  x::T
end

NLogWeight(x::Number) = NLogWeight(float(x))

zero(::Type{NLogWeight{T}}) where T = NLogWeight{T}(T(Inf))
one(::Type{NLogWeight{T}}) where T = NLogWeight{T}(zero(T))

*(a::NLogWeight{T}, b::NLogWeight{T}) where {T <: AbstractFloat} = NLogWeight{T}(a.x + b.x)
+(a::NLogWeight{T}, b::NLogWeight{T}) where {T <: AbstractFloat} = NLogWeight{T}(-logadd(-a.x,-b.x))
/(a::NLogWeight{T}, b::NLogWeight{T}) where {T <: AbstractFloat} = NLogWeight{T}(a.x - b.x)
reverse(a::NLogWeight) = a

# parsing
parse(::Type{S},str) where {T, S <: NLogWeight{T}} = S(parse(T,str))

#properties
iscommutative(::Type{W}) where {W <: NLogWeight} = true
isleft(::Type{W}) where {W <: NLogWeight} = true
isright(::Type{W}) where {W <: NLogWeight}= true
isweaklydivisible(::Type{W}) where {W <: NLogWeight}= true
iscomplete(::Type{W}) where {W <: NLogWeight}= true
