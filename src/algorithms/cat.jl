# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

import Base:*
"""
  `*(A::WFST,B::WFST)`

Returns `C`, the concatenation/product of `A` and `B`. If `A` converts the sequence `a_i` to `a_o` with weight `wa` and `B` converts the sequence `b_i` to `b_o` with weight `wb` then C` converts the sequence `[a_i,b_i]` to `[a_o,b_o]` with weight `wa*wb`.

```julia
julia> sym = ["a","b","c","d","α","β","γ","δ"];

julia> A = WFST(sym);

julia> add_arc!(A,1=>2,"a"=>"α");

julia> add_arc!(A,2=>3,"b"=>"β");

julia> initial!(A,1); final!(A,3,5)
WFST #states: 3, #arcs: 2, #isym: 8, #osym: 8
|1/0.0f0|
a:α/0.0f0 → (2)
(2)
b:β/0.0f0 → (3)
((3/5.0f0))

julia> B = WFST(sym);

julia> add_arc!(B,1=>2,"c"=>"γ");

julia> add_arc!(B,2=>3,"d"=>"δ");

julia> initial!(B,1); final!(B,3,2)
WFST #states: 3, #arcs: 2, #isym: 8, #osym: 8
|1/0.0f0|
c:γ/0.0f0 → (2)
(2)
d:δ/0.0f0 → (3)
((3/2.0f0))

julia> C = A*B
WFST #states: 6, #arcs: 5, #isym: 8, #osym: 8
|1/0.0f0|
a:α/0.0f0 → (2)
(2)
b:β/0.0f0 → (3)
(3)
ϵ:ϵ/5.0f0 → (4)
(4)
c:γ/0.0f0 → (5)
(5)
d:δ/0.0f0 → (6)
((6/2.0f0))

julia> A(["a","b"])
(["α", "β"], 5.0f0)

julia> B(["c","d"])
(["γ", "δ"], 2.0f0)

julia> C(["a","b","c","d"])
(["α", "β", "γ", "δ"], 7.0f0)

```
"""
function *(A::WFST,B::WFST)
  isym = get_isym(A)
  osym = get_osym(A)
  W = typeofweight(A)
  if isym != get_isym(B)
    throw(ErrorException("WFSTs have different input symbol tables"))
  end
  if osym != get_osym(B)
    throw(ErrorException("WFSTs have different output symbol tables"))
  end
  if W != typeofweight(B)
    throw(ErrorException("WFSTs have different type of weigths $W and $(typeofweight(B))"))
  end
  C = deepcopy(A)
  offset = length(C)
  add_states!(C,length(B))
  for (q,arcs) in enumerate(get_states(B))
    for arc in arcs
      ilab, olab = get_ilabel(arc), get_olabel(arc)
      w, n = get_weight(arc), get_nextstate(arc)
      push!(C[q+offset],Arc(ilab,olab,w,n+offset)) 
    end
  end
  final_A = get_final(A; single=false)
  initial_B = get_initial(B; single=false)
  for (qf,wf) in final_A
    for (qi,wi) in initial_B
      push!(C[qf],Arc(0,0,wf*wi,qi+offset))
    end
    rm_final!(C,qf)
  end
  for (q,w) in get_final(B; single=false)
    final!(C,q+offset,w)
  end
  return C
end
