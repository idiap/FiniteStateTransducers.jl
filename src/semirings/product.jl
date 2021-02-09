# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export ProductWeight

"""
`ProductWeight(x...)`

| Set                                               |           ``\\oplus``                                                     |   ``\\otimes``                                                              | ``\\bar{0}``                                                 | ``\\bar{1}``                                                 |
|:-------------------------------------------------:|:-------------------------------------------------------------------------:|:---------------------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|
|``\\mathbb{W}_1\\times \\dots\\times\\mathbb{W}_N``|  ``\\oplus_{\\mathbb{W}_1} \\times \\dots\\times\\oplus_{\\mathbb{W}_N}`` |  ``\\otimes_{\\mathbb{W}_1} \\times \\dots\\times\\otimes_{\\mathbb{W}_N}`` |``(\\bar{0}_{\\mathbb{W}_1},\\dots,\\bar{0}_{\\mathbb{W}_N})``|``(\\bar{1}_{\\mathbb{W}_1},\\dots,\\bar{1}_{\\mathbb{W}_N})``| 

"""
struct ProductWeight{N, T <:NTuple{N,Semiring} } <: Semiring
  x::T
end
ProductWeight(x...) = ProductWeight(x)
reversetype(::Type{S}) where {N,T,S <: ProductWeight{N,T}} =
ProductWeight{N,Tuple{reversetype.(fieldtypes(T))...}}
ProductWeight{N,T}(x::ProductWeight{N,T}) where {N,T <:NTuple{N,Semiring}} = x

zero(::Type{ProductWeight{N,T}}) where {N,T}  = ProductWeight{N,T}(zero.(fieldtypes(T)))
one(::Type{ProductWeight{N,T}}) where {N,T}  = ProductWeight{N,T}(one.(fieldtypes(T)))

*(a::ProductWeight{N,T}, b::ProductWeight{N,T}) where {N,T} = ProductWeight{N,T}(a.x .* b.x)
+(a::ProductWeight{N,T}, b::ProductWeight{N,T}) where {N,T} = ProductWeight{N,T}(a.x .+ b.x)
/(a::ProductWeight{N,T}, b::ProductWeight{N,T}) where {N,T} = ProductWeight{N,T}(a.x ./ b.x)
reverse(a::ProductWeight{N,T}) where {N,T} = ProductWeight{N,T}t(reverse.(a.x))

# properties
for p in [:isleft,
          :isright,
          :isweaklydivisible,
          :ispath,
          :isidempotent,
          :iscommulative,
          :iscomplete]
  @eval $p(::Type{ProductWeight{N,T}}) where {N,T} = all( $p.(fieldtypes(T))  )          
end
