# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

import Base:reverse
"""
  `reverse(fst::WFST)`

Returns `rfst`, the reversed version of `fst`.
If `fst` transuces the sequence `x` to `y` with weight `w`, `rfst` transuces the reverse of `x` to the reverse of `y` with weight `reverse(w)`.
"""
function reverse(fst::WFST{W,A,D}) where {W,A,D}
  RW = FiniteStateTransducers.reversetype(W)
  rfst = WFST(get_isym(fst),get_osym(fst); W = RW)

  add_states!(rfst,length(fst)+1)
  initial!(rfst,D(1)) # 1 is an additional initial superstate

  for (q,arcs) in enumerate(get_states(fst))
    qr = D(q+1) # reversed state
    if isinitial(fst,q)
      w = get_weight(fst,q)
      final!(rfst,qr,reverse(w))
    end
    if isfinal(fst,q)
      w = get_weight(fst,q)
      push!(rfst[1], Arc{RW,D}(D(0),D(0),reverse(w),qr))
    end
    for arc in arcs
      n = get_nextstate(arc)+1
      w = get_weight(arc)
      ilab, olab= get_ilabel(arc), get_olabel(arc)
      push!(rfst[n], Arc{RW,D}(ilab,olab,reverse(w),qr))
    end
  end

  return rfst

end
