# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export LogWeight

"""
`LogWeight(x)`

| Set                                 |     ``\\oplus``      |  ``\\otimes``  | ``\\bar{0}`` | ``\\bar{1}`` |
|:-----------------------------------:|:--------------------:|:--------------:|:------------:|:------------:|
|``\\mathbb{R}\\cup\\{\\pm\\infty\\}``|``\\log(e^{x}+e^{y})``|     ``+``      |``-\\infty``  |   ``0``      | 
"""
struct LogWeight{T <: AbstractFloat} <: Semiring
  x::T
end

LogWeight(x::Number) = LogWeight(float(x))

zero(::Type{LogWeight{T}}) where T = LogWeight{T}(T(-Inf))
one(::Type{LogWeight{T}}) where T = LogWeight{T}(zero(T))

*(a::LogWeight{T}, b::LogWeight{T}) where {T <: AbstractFloat} = LogWeight{T}(a.x + b.x)
+(a::LogWeight{T}, b::LogWeight{T}) where {T <: AbstractFloat} = LogWeight{T}(logadd(a.x,b.x))
/(a::LogWeight{T}, b::LogWeight{T}) where {T <: AbstractFloat} = LogWeight{T}(a.x - b.x)
reverse(a::LogWeight) = a
function logadd(y::T, x::T) where {T <: AbstractFloat} 
  if isinf(x) return y end
  if isinf(y) return x end
  if x < y
    diff = x-y
    x = y 
  else
    diff = y-x
  end
  return x + log1p(exp(diff))
end

# parsing
parse(::Type{S},str) where {T, S <: LogWeight{T}} = S(parse(T,str))

#properties
iscommutative(::Type{W}) where {W <: LogWeight} = true
isleft(::Type{W}) where {W <: LogWeight} = true
isright(::Type{W}) where {W <: LogWeight}= true
isweaklydivisible(::Type{W}) where {W <: LogWeight}= true
iscomplete(::Type{W}) where {W <: LogWeight}= true
