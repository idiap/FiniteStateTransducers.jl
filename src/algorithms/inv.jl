# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

"""
`inv(fst::WFST)`

Inverts `fst` such that input labels are swaped with output labels.

```julia
julia> A = linearfst(["a","b","c"],[1,2,3],ones(3))
WFST #states: 4, #arcs: 3, #isym: 3, #osym: 3
|1/1.0|
a:1/1.0 → (2)
(2)
b:2/1.0 → (3)
(3)
c:3/1.0 → (4)
((4/1.0))


julia> inv(A)
WFST #states: 4, #arcs: 3, #isym: 3, #osym: 3
|1/1.0|
1:a/1.0 → (2)
(2)
2:b/1.0 → (3)
(3)
3:c/1.0 → (4)
((4/1.0))
```
"""
function Base.inv(fst::WFST)
  ifst = arcmap(inv, fst)
  ifst = WFST(ifst.states,ifst.initials,ifst.finals,ifst.osym,ifst.isym)
  return ifst 
end
