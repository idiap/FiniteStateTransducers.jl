# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export connect!
"""
  `connect!(fst::WFST, [i = get_initial(fst,single=true)])`

Same as `connect` but modifies `fst` in-place.
"""
function connect!(fst::WFST, i = get_initial(fst,single=true))
  if !isempty(fst)
    scc, c, v = get_scc(fst,i)
    idxs = findall( (|).((!).(v),(!).(c)) )
    return rm_state!(fst,idxs)
  else
    return fst
  end
end

export connect
"""
  `connect(fst::WFST, [i = get_initial(fst,single=true)])`

Remove states that do not belong to paths that end in final states when starting from `i`.
"""
function connect(fst::WFST, args...)
  fst_copy = deepcopy(fst)
  connect!(fst_copy, args...)
  return fst_copy
end
