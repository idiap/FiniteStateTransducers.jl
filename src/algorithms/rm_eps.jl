# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export rm_eps!
# follows M. MOHRI GENERIC ∊-REMOVAL AND INPUT∊-NORMALIZATION ALGORITHMS FOR WEIGHTED TRANSDUCERS
# many optimizations are currently missing 
"""
  `rm_eps!(fst::WFST)`

Same as `rm_eps` but operates in place.
"""
function rm_eps!(fst::WFST{W,A,D}) where {W,A,D}
  iseps_arc = arc -> iseps(get_ilabel(arc)) && iseps(get_olabel(arc))
  for (p,s) in enumerate(get_states(fst))
    arcs_to_rm = D[]
    new_arcs = Tuple{D,Arc{W,D}}[]
    for (i,arc) in enumerate(s)
      if iseps_arc(arc) 
        push!(arcs_to_rm,i)
      end
      # get closure on Aϵ
      C = shortest_distance(fst,p; filter=iseps_arc) 
      # TODO this allocate stuff... would make sense that C is also sparse?
      for (q,w) in enumerate(C)
        if w != zero(W)
          for a in fst[q]
            if !iseps_arc(a)
              new_arc=Arc{W,D}(
                               get_ilabel(a),
                               get_olabel(a),
                               get_weight(a) * w,
                               get_nextstate(a)
                              )
              push!(new_arcs, (p,new_arc))
            end
          end
          if isfinal(fst,q)
            if !isfinal(fst,p)
              final!(fst,p,zero(W))
            end
            fst.finals[p] += w * fst.finals[q] 
          end
        end
      end
    end
    deleteat!(s,arcs_to_rm)
    for (p,a) in new_arcs
      push_arc!(fst,p,a)
    end
    unique!(fst[p]) # avoids multiple arcs with same i/o 
  end
  connect!(fst)
  return fst
end

export rm_eps
"""
  `rm_eps(fst::WFST)`

Returns an equivalent WFST where arcs with input and output labels are removed.
"""
function rm_eps(fst::WFST)
  new_fst = deepcopy(fst)
  rm_eps!(new_fst)
end
