# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export proj
"""
`proj(iolabel::Function, fst::WFST)`

Projects input labels to output labels (or viceversa).
The function `get_iolabel` should either be the function `get_ilabel` or `get_olabel`.
"""
function proj(get_iolabel::Function, fst::WFST)
  if !( (get_iolabel == get_ilabel) || (get_iolabel == get_olabel) )
    throw(ErrorException("Input function should be either `ilabel` or `olabel`."))
  end
  pfst = arcmap(proj, fst, get_iolabel)
  if get_iolabel == get_ilabel
    pfst = WFST(pfst.states,pfst.initials,pfst.finals,pfst.isym,pfst.isym)
  else
    pfst = WFST(pfst.states,pfst.initials,pfst.finals,pfst.osym,pfst.osym)
  end
  return pfst
end
