# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export BoolWeight

"""
`BoolWeight(x::Bool)`

| Set           |     ``\\oplus``      |  ``\\otimes``  | ``\\bar{0}`` | ``\\bar{1}`` |
|:-------------:|:--------------------:|:--------------:|:------------:|:------------:|
| ``\\{0,1\\}`` |       ``\\lor``      |  ``\\land``    |   ``0``      |    ``1``     | 
"""
struct BoolWeight <: Semiring
  x::Bool
end

zero(::Type{BoolWeight}) = BoolWeight(false)
one(::Type{BoolWeight}) = BoolWeight(true)

*(a::BoolWeight, b::BoolWeight) = BoolWeight(a.x && b.x)
+(a::BoolWeight, b::BoolWeight) = BoolWeight(a.x || b.x)

#properties
isidempotent(::Type{W}) where {W <: BoolWeight} = true
iscommutative(::Type{W}) where {W <: BoolWeight} = true
isleft(::Type{W}) where {W <: BoolWeight}= true
isright(::Type{W}) where {W <: BoolWeight}= true
ispath(::Type{W}) where {W <: BoolWeight}= true
iscomplete(::Type{W}) where {W <: BoolWeight}= true
