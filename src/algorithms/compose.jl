# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

import Base: ∘
"""
 `∘(A::WFST,B::WFST; filter=EpsSeq, connect=true)`

Perform composition of the transucers `A` and `B`.

The keyword `filter` can specify the composition filter to be used.

If `connect` is set to `true` after completing the composition the [`connect`](@ref) algorithm is applied. 

See [Allauzen et al. "Filters for Efficient Composition of Weighted Finite-State Transducers"](https://doi.org/10.1007/978-3-642-18098-9_4)
"""
function ∘(A::WFST{W1,A1,D,I1,O1}, B::WFST{W2,A2,D,I2,O2};
           filter=EpsSeq, connect=true
          ) where {W1, W2, D, I1, I2, O1, O2, 
                   A1 <: Arc{W1,D}, 
                   A2 <: Arc{W2,D}}
  if O1 != I2
    error("Output label of A must be of the same type of input labels of B.")
  end
  if W1 != W2
    error("Weights of A must be of the same type of weights of B.")
  end
  if !(A.osym === B.isym) 
    if A.osym != B.isym # construncting A and B using the same object avoids this check
      throw(ErrorException("Output symbol table of A not consistent with input symbol table of B."))
    end
  end

  function updateC!(it::ComposeIterator,
                    i::D,q1::D,q2::D,q3::D,w3::W,
                    e1::Arc{W,D},e2::Arc{W,D},
                    src::D,dest::D) where {W,A,D}
    wc = get_weight(e1)*get_weight(e2)
    if max(src,dest) - length(it.C) > 0 
      add_states!(it.C, max(src,dest) - length(it.C) )  # eventually expand states
    end
    push_arc!(it.C,src,Arc(get_ilabel(e1),get_olabel(e2),wc,dest)) 
  end

  function updateCfinal!(it::ComposeIterator,
                         i::D,q1::D,q2::D,q3::D,w3::W,
                         src::D) where {W,A,D}
    if isinitial(it.A,q1) && isinitial(it.B,q2)
      w1, w2 = get_initial_weight(it.A,q1), get_initial_weight(it.B,q2)
      initial!(it.C, src, w1*w2) 
    end
    if isfinal(it.A,q1) && isfinal(it.B,q2) && 
      q3 <= it.filter.q_max && w3 != zero(typeof(w3))
      w1, w2 = get_final_weight(it.A,q1), get_final_weight(it.B,q2)
      final!(it.C, src, w1*w2*w3) 
    end
  end

  ϵ  = 0
  ϵL = max(length(get_osym(A)),length(get_isym(B)))+1
  f = filter{W1,D}(ϵL)
  # add self loops
  for i in 1:size(A,1)
    push_arc!(A,i,Arc{W1,D}(ϵ,ϵL,one(W1),i))
  end
  for i in 1:size(B,1)
    push_arc!(B,i,Arc{W1,D}(ϵL,ϵ,one(W1),i))
  end
  C = WFST(get_isym(A),get_osym(B); W = W1)
  z = ComposeIterator(A,B,C,f,updateC!,updateCfinal!)
  for zi in z
    nothing
  end
  # delete self loops
  for s in get_states(A) deleteat!(s,length(s)) end
  for s in get_states(B) deleteat!(s,length(s)) end
  if connect
    connect!(C)
  end
  return C
end
