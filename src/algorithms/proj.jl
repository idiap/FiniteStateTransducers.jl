# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export proj
"""
`proj(get_iolabel::Function, fst::WFST)`

Projects input labels to output labels (or viceversa).
The function `get_iolabel` should either be the function `get_ilabel` or `get_olabel`.

julia> A = linearfst(["a","b","c"],[1,2,3],ones(3))
WFST #states: 4, #arcs: 3, #isym: 3, #osym: 3
|1/1.0|
a:1/1.0 → (2)
(2)
b:2/1.0 → (3)
(3)
c:3/1.0 → (4)
((4/1.0))

julia> proj(get_ilabel, A)
WFST #states: 4, #arcs: 3, #isym: 3, #osym: 3
|1/1.0|
a:a/1.0 → (2)
(2)
b:b/1.0 → (3)
(3)
c:c/1.0 → (4)
((4/1.0))

julia> proj(get_olabel, A)
WFST #states: 4, #arcs: 3, #isym: 3, #osym: 3
|1/1.0|
1:1/1.0 → (2)
(2)
2:2/1.0 → (3)
(3)
3:3/1.0 → (4)
((4/1.0))
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
