# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export LeftStringWeight

"""
`LeftStringWeight(x)`

| Set                     |           ``\\oplus``  |  ``\\otimes``  | ``\\bar{0}`` | ``\\bar{1}`` |
|:-----------------------:|:----------------------:|:--------------:|:------------:|:------------:|
|``L^*\\cup\\{\\infty\\}``|  longest common prefix |     ``\\cdot`` |``\\infty``   |``\\epsilon`` | 

where ``L^*`` is Kleene closure of the set of characters ``L`` and ``\\epsilon`` the empty string.
"""
struct LeftStringWeight <: Semiring
  x::String
  iszero::Bool
end
LeftStringWeight(x::String) = LeftStringWeight(x,false)
reversetype(::Type{S}) where {S <: LeftStringWeight} = RightStringWeight

zero(::Type{LeftStringWeight}) = LeftStringWeight("",true)
one(::Type{LeftStringWeight})  = LeftStringWeight("",false)

# longest common prefix
function lcp(a::LeftStringWeight,b::LeftStringWeight)
  if a.iszero
    return b
  elseif b.iszero
    return a
  else
    cnt = 0
    for x in zip(a.x,b.x)
      if x[1] == x[2]
        cnt +=1
      else
        break
      end
    end
    return LeftStringWeight(a.x[1:cnt])
  end
end

*(a::T, b::T) where {T<:LeftStringWeight}= 
((a.iszero) | (b.iszero)) ? zero(T) : T(a.x * b.x)
+(a::LeftStringWeight, b::LeftStringWeight) = lcp(a,b)
function /(a::LeftStringWeight, b::LeftStringWeight)
  if b == zero(LeftStringWeight)
    throw(ErrorException("Cannot divide by zero"))
  elseif a == zero(LeftStringWeight)
    return zero(LeftStringWeight)
  else
    str = ""
    for i=1:length(a.x)
      if i > length(b.x)
        str *= a.x[i] 
      end
    end
    return LeftStringWeight(str)
  end
end
reverse(a::LeftStringWeight) = RightStringWeight(reverse(a.x),a.iszero)

#properties
isidempotent(::Type{W}) where {W <: LeftStringWeight} = true
isleft(::Type{W}) where {W <: LeftStringWeight}= true
isweaklydivisible(::Type{W}) where {W <: LeftStringWeight}= true
