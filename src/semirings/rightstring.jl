# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export RightStringWeight

"""
`RightStringWeight(x)`

| Set                     |        ``\\oplus``     |   ``\\otimes`` | ``\\bar{0}`` | ``\\bar{1}`` |
|:-----------------------:|:----------------------:|:--------------:|:------------:|:------------:|
|``L^*\\cup\\{\\infty\\}``|  longest common suffix |     ``\\cdot`` |``\\infty``   |``\\epsilon`` | 

where ``L^*`` is Kleene closure of the set of characters ``L`` and ``\\epsilon`` the empty string.
"""
struct RightStringWeight <: Semiring
  x::String
  iszero::Bool
end
RightStringWeight(x::String) = RightStringWeight(x,false)
reversetype(::Type{S}) where {S <: RightStringWeight} = LeftStringWeight

zero(::Type{RightStringWeight}) = RightStringWeight("",true)
one(::Type{RightStringWeight})  = RightStringWeight("",false)

# longest common suffix
function lcs(a::RightStringWeight,b::RightStringWeight)
  if a.iszero 
    return b
  elseif b.iszero
    return a
  else
    cnt = 0
    for x in zip(reverse(a.x),reverse(b.x))
      if x[1] == x[2]
        cnt +=1
      else
        break
      end
    end
    return RightStringWeight(a.x[end-cnt+1:end])
  end
end

*(a::T, b::T) where {T<:RightStringWeight}= 
((a.iszero) | (b.iszero)) ? zero(T) : T(a.x * b.x)
+(a::RightStringWeight, b::RightStringWeight) = lcs(a,b)
function /(a::RightStringWeight, b::RightStringWeight)
  if b == zero(RightStringWeight)
    throw(ErrorException("Cannot divide by zero"))
  elseif a == zero(RightStringWeight)
    return a
  end
  return RightStringWeight(a.x[1:end-length(b.x)])
end
reverse(a::RightStringWeight) = LeftStringWeight(reverse(a.x),a.iszero)

#properties
isidempotent(::Type{W}) where {W <: RightStringWeight} = true
isright(::Type{W}) where {W <: RightStringWeight}= true
isweaklydivisible(::Type{W}) where {W <: RightStringWeight}= true
