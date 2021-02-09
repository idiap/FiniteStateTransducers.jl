# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# this makes work e.g. TropicalWeight{Float32}(x::TropicalWeight{Float64})
for W in [:TropicalWeight=>:AbstractFloat, 
          :ProbabilityWeight=>:AbstractFloat, 
          :NLogWeight=>:AbstractFloat, 
          :LogWeight=>:AbstractFloat,
         ]
  @eval $(W[1]){T}(x::$(W[1]){TT}) where {T<:$(W[2]),TT<:$(W[2])} = $(W[1]){T}(T(x.x))
  @eval $(W[1]){T}(x::$(W[1]){T}) where {T<:$(W[2])} = x
end
for W in [:LeftStringWeight,:RightStringWeight,:BoolWeight,:ProductWeight]
  @eval $(W)(x::$(W)) = x
end

#parse
for W in [:TropicalWeight, 
          :ProbabilityWeight, 
          :NLogWeight,
          :LogWeight,
         ]
  @eval parse(::Type{$(W){T}},str) where T = $(W)(parse(T,str))
end
parse(::Type{S},str) where {S <: BoolWeight} = S(parse(Bool,str))
