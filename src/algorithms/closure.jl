# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export closure!
"""
  `closure!(fst; star=true)`

Same as `closure` but modifies `fst` in-place.

"""
function closure!(fst; star=true)
  if star
    fst = closure_star!(fst)
  else
    fst = closure_plus!(fst)
  end
  return fst
end

export closure
"""
  `closure(fst; star=true)`

Returns a new WFST `cfst` that is the closure of `fst`. 
If `fst` transuces `labels` to `olabel` with weight `w`, `cfst` will be able to transduce `repeat(ilabels,n)` to `repeat(olabels,m)` with weight `w^n` for any integer `n`.

If `star` is `true`, `cfst` will transduce the empty string to itself with weight one.

"""
function closure(fst; star=true)
  fst_copy = deepcopy(fst)
  closure!(fst_copy; star=star)
  return fst_copy
end

function closure_plus!(fst::WFST{W,A,D,I,O}) where {W,A,D,I,O}
  ϵi, ϵo = get_eps(I), get_eps(O)
  i = get_initial(fst; single=true) 
  for k in keys(get_final(fst; single=false))
    w = get_final_weight(fst,k)
    add_arc!(fst,k,i,ϵi,ϵo,w)
  end
  return fst
end

function closure_star!(fst::WFST{W,A,D,I,O}) where {W,A,D,I,O}
  ϵi, ϵo = get_eps(I), get_eps(O)
  closure_plus!(fst)
  i = get_initial(fst,single=true)
  w = get_initial_weight(fst,i)
  rm_initial!(fst,i)
  ni = size(fst,1)+1
  add_arc!(fst,ni,i,ϵi,ϵo,w)
  initial!(fst,ni)
  final!(fst,ni)
  return fst
end
