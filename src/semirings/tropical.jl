# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export TropicalWeight

"""
`TropicalWeight(x)`

| Set                                 | ``\\oplus``|   ``\\otimes`` | ``\\bar{0}`` | ``\\bar{1}`` |
|:-----------------------------------:|:----------:|:--------------:|:------------:|:------------:|
|``\\mathbb{R}\\cup\\{\\pm\\infty\\}``|  ``\\min`` |     ``+``      |``\\infty``   |   ``0``      | 
"""
struct TropicalWeight{T <: AbstractFloat} <: Semiring
  x::T
end

zero(::Type{TropicalWeight{T}}) where T = TropicalWeight{T}(T(Inf))
one(::Type{TropicalWeight{T}}) where T = TropicalWeight{T}(zero(T))

*(a::TropicalWeight{T}, b::TropicalWeight{T}) where {T <: AbstractFloat} = TropicalWeight{T}(a.x + b.x)
+(a::TropicalWeight{T}, b::TropicalWeight{T}) where {T <: AbstractFloat} = TropicalWeight{T}( min(a.x,b.x) )
/(a::TropicalWeight{T}, b::TropicalWeight{T}) where {T <: AbstractFloat} = TropicalWeight{T}( a.x-b.x )

# parsing
parse(::Type{S},str) where {T, S <: TropicalWeight{T}} = S(parse(T,str))

#properties
isidempotent(::Type{W}) where {W <: TropicalWeight} = true
iscommulative(::Type{W}) where {W <: TropicalWeight} = true
isleft(::Type{W}) where {W <: TropicalWeight}= true
isright(::Type{W}) where {W <: TropicalWeight}= true
isweaklydivisible(::Type{W}) where {W <: TropicalWeight}= true
iscomplete(::Type{W}) where {W <: TropicalWeight}= true
ispath(::Type{W}) where {W <: TropicalWeight}= true
