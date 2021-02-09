# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export iseps
"""
  `iseps(x)`

Checks if `x` is the epsilon label. Defined only for `String` and `Int`, where `<eps>` and `0` are the epsilon symbols. Extend this method if you want to create WFST with a user defined type.
"""
iseps(x::T) where {T<:Integer} = x == zero(T)
iseps(x::String) = x == "<eps>"
iseps(x::Char) = x == 'ϵ'

export get_eps
"""
  `get_eps(x::Type)`

Returns the epsilon label for a given `Type`. Defined only for `String` and `Int`, where `<eps>` and `0` are the epsilon symbols. Extend this method if you want to create WFST with a user defined type.
"""
get_eps(x::Type{T}) where {T<:Integer} = T(0)
get_eps(x::Type{String}) = "<eps>"
get_eps(x::Type{Char}) = 'ϵ'
