# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export Arc, get_ilabel, get_olabel, get_weight, get_nextstate
"""
  `Arc(ilab::Int,olab::Int,w::W,n::Int)`

Constructs an arc with input label `ilab`, output label `olab`, weight 'weight' and nextstate `n`.
`ilab` and `olab` must be integers consistent with a input/output symbol table of the WFST at use.

Mainly used for internals see [`add_arc!`](@ref) for a simpler way of adding arcs to a WFST.   
"""
struct Arc{W,D}
  ilabel::D      # input label
  olabel::D      # output label
  weight::W      # weight
  nextstate::D   # destination id
end

import Base: ==

function ==(a::Arc,b::Arc; check_weight=true) 
  i = (a.ilabel == b.ilabel) 
  o = (a.olabel == b.olabel)
  d = (a.nextstate == b.nextstate)
  if check_weight
    w = (a.weight == b.weight)
    return i && o && d && w
  else
    return i && o && d
  end
end

function Base.show(io::IO, A::Arc, isym::Dict, osym::Dict)
  ilabel = idx2string(A.ilabel,isym)
  olabel = idx2string(A.olabel,osym)
  print(io, "$(ilabel):$(olabel)/$(A.weight) → ($(A.nextstate))")
end

function Base.show(io::IO, A::Arc)
  print(io, "$(A.ilabel):$(A.olabel)/$(A.weight) → ($(A.nextstate))")
end

function idx2string(label,sym)
  if iseps(label)
    return "ϵ"
  else
    return "$(sym[label])"
  end
end

"""
`get_ilabel(A::Arc)`

Returns the input label index of the arc `A`.
"""
get_ilabel(A::Arc) = A.ilabel

"""
`get_olabel(A::Arc)`

Returns the input label index of the arc `A`.
"""
get_olabel(A::Arc) = A.olabel

"""
`get_weight(A::Arc)`

Returns the weight the arc `A`.
"""
get_weight(A::Arc) = A.weight

"""
`get_nextstate(A::Arc)`

Returns the state that the arc `A` is pointing to.
"""
get_nextstate(A::Arc) = A.nextstate

change_next(a::Arc{W,D}, nextstate::D) where {W,D} = Arc{W,D}(get_ilabel(a), 
                                                              get_olabel(a),
                                                              get_weight(a),
                                                              nextstate)
Base.inv(a::Arc) = Arc(get_olabel(a),get_ilabel(a),get_weight(a),get_nextstate(a))
proj(a::Arc, get_iolabel::Function) = Arc(get_iolabel(a),get_iolabel(a),get_weight(a),get_nextstate(a))
