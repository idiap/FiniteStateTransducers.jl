# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

struct ComposeIterator{D<:Integer,
                       F1<:WFST,
                       F2<:WFST,
                       F3,
                       CF
                      }
  A::F1
  B::F2
  C::F3      # this can be anything you need to build (e.g. a WFST)
  filter::CF # composition filter
  updateC!::Function      # modify C in place
  updateCfinal!::Function # modify C in place (after all arcs)
  function ComposeIterator(A::F1,
                           B::F2,
                           C::F3,
                           filter::CF,
                           updateC!,
                           updateCfinal!
                          ) where {D,W,I,O,O2,
                                   A1 <: Arc{W,D},
                                   F1 <: WFST{W,A1,D,I,O},
                                   F2 <: WFST{W,A1,D,O,O2},
                                   F3,
                                   CF
                                  }
    new{D,F1,F2,F3,CF}(A,B,C,filter,updateC!,updateCfinal!)
  end
end

function init(it::ComposeIterator{D}) where {D}
  Q = Dict{Tuple{D,D,D},D}()
  S = Queue{Tuple{D,D,D}}()
  i1 = get_initial(it.A, single=true)
  i2 = get_initial(it.B, single=true)
  src = 1 #new state for C 
  i3 = it.filter.i3
  push!(Q, (i1,i2,i3) => src)
  enqueue!(S,(i1,i2,i3))
  return Q, S, src
end

function Base.iterate(it::ComposeIterator, it_st=init(it))
  Q, S, i = it_st
  if isempty(S)
    return nothing
  else
    q = dequeue!(S)
    q1, q2, q3 = q[1],q[2],q[3]
    arcs1 = it.A[q1]
    arcs2 = it.B[q2]
    w3 = it.filter.rho[q3]
    src = Q[q]

    for e1 in arcs1, e2 in arcs2
      e1, e2, q3_new = phi(it.filter, e1, e2, q3)
      if q3_new != 0
        n = get_nextstate(e1), get_nextstate(e2), q3_new
        if !(n in keys(Q)) 
          i += 1
          enqueue!(S,n)
          push!(Q, n => i)
        end
        dest = Q[n]
        it.updateC!(it,i,q1,q2,q3,w3,e1,e2,src,dest)
      end
    end
    it.updateCfinal!(it,i,q1,q2,q3,w3,src)
    return i, (Q, S, i)
  end
end
