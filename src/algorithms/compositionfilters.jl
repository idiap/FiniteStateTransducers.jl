# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# using filters from paper 
# Allauzen et al. Filters for Efficient Composition of Weighted Finite-State Transducers
# main differences here are that we use ⟂ = 0 and base 1 index for the states
abstract type CompositionFilter end

export Trivial
"""
`Trivial`

Simplest composition filter, can be used for epsilon-free WFSTs.
"""
struct Trivial{W,D} <: CompositionFilter
  i3::D
  q_max::D
  rho::Vector{W}
  ϵL::D
  Trivial{W,D}(ϵL::D) where {W,D} = new{W,D}(1,2,[one(W),one(W)],ϵL)
end

function phi(filter::Trivial, e1, e2, q3)
  ϵL = filter.ϵL
  o_e1, i_e2 = get_olabel(e1), get_ilabel(e2)
  if (o_e1 == i_e2) || 
    (o_e1 == ϵL && i_e2 == 0) || 
    (o_e1 == 0 && i_e2 == ϵL)
    if iseps(get_ilabel(e1)) && iseps(get_olabel(e2))
      # avoids self eps:eps loops
      return e1, e2, 0 
    else
      return e1, e2, 1 
    end
  else
    return e1, e2, 0
  end
end

export EpsMatch
"""
`EpsMatch`

Can be used for WFSTs containing epsilon labels.
Avoids redundant epsilon paths and giving priority to those that match epsilon labels. 
"""
struct EpsMatch{W,D} <: CompositionFilter
  i3::D
  q_max::D
  rho::Vector{W}
  ϵL::D
  EpsMatch{W,D}(ϵL::D) where {W,D} = 
  new{W,D}(1,3,[one(W),one(W),one(W)],ϵL)
end

function phi(filter::EpsMatch, e1, e2, q3)
  ϵL = filter.ϵL
  o_e1, i_e2 = get_olabel(e1), get_ilabel(e2)
  if (o_e1 == i_e2) && 
    !(iseps(o_e1) || o_e1 == ϵL) && 
    !(iseps(i_e2) || i_e2 == ϵL)
    return e1, e2, 1 
  elseif (o_e1 == 0) && (i_e2 == 0) && (q3 == 1)
    return e1, e2, 1
  elseif (o_e1 == ϵL) && (i_e2 == 0) && (q3 != 3)
    return e1, e2, 2
  elseif (o_e1 == 0) && (i_e2 == ϵL) && (q3 != 2)
    return e1, e2, 3
  else 
    return e1, e2, 0
  end
end

export EpsSeq
"""
`EpsSeq`

Can be used for WFSTs containing epsilon labels.
Avoids redundant epsilon paths. 
Gives priority to epsilon paths consisting of epsilon-arcs in `A` followed by epsilon-arcs in `B`. 
"""
struct EpsSeq{W,D} <: CompositionFilter
  i3::D
  q_max::D
  rho::Vector{W}
  ϵL::D
  EpsSeq{W,D}(ϵL::D) where {W,D} = 
  new{W,D}(1,2,[one(W),one(W)],ϵL::D)
end

function phi(filter::EpsSeq, e1, e2, q3)
  ϵL = filter.ϵL
  o_e1, i_e2 = get_olabel(e1), get_ilabel(e2)
  if (o_e1 == i_e2) && 
    !(iseps(o_e1) || o_e1 == ϵL) && 
    !(iseps(i_e2) || i_e2 == ϵL)
    return e1, e2, 1 
  elseif (o_e1 == 0) && (i_e2 == ϵL) && (q3 == 1)
    return e1, e2, 1
  elseif (o_e1 == ϵL) && (i_e2 == 0)
    return e1, e2, 2
  else 
    return e1, e2, 0
  end
end
