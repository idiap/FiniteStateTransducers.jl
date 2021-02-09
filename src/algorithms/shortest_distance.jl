# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export shortest_distance

"""
  `shortest_distance(fst[, s=get_initial(fst); filter=arc->true, reverse=false)`

Computes the shortest distance between the state `s` to every other state.
The shortest distance between `s` and `i` is defined as the sum of the weights of all paths between these states.

Weights are required to be rigth distributive and k-closed.

If `fst` has `N` states a `N`-long vector is returned where the `i`-the element contains the shortest distance between the states `s` and `i`.

If `reversed==true` the shortest distance from the final states is computed.
In this case `s` has no effect since a new initial superstate is added to the reversed WFST.
Here weights are required to be left distributive and k-closed. 

See Mohri "Semiring framework and algorithms for shortest-distance problems", Journal of Automata, Languages and Combinatorics 7(3): 321-350, 2002.

"""
function shortest_distance(fst::WFST{W}, s=get_initial(fst); filter=arc->true, reversed=false) where {W}

  if reversed
    if !isright(W)
      throw(ErrorException("Weight $W is not right distributive"))
    end
    if !ispath(W)
      throw(ErrorException("Weight $W must satisfy the \"path\" property"))
    end

    rfst = reverse(fst)
    d = no_check_shortest_distance(rfst,get_initial(rfst);filter=filter)
    return d[2:end]
  else
    if !isleft(W)
      throw(ErrorException("Weight $W is not left distributive"))
    end
    if !ispath(W)
      throw(ErrorException("Weight $W must satisfy the \"path\" property"))
    end
    return no_check_shortest_distance(fst,s;filter=filter)
  end

end

function no_check_shortest_distance(fst::WFST{W,A,D},
                                    s::D=get_initial(fst);
                                    filter=arc->true) where {W,A,D}
  Ns = size(fst,1)
  d = zeros(W,Ns) # d[q] estimate of shortest distance between q and s
  r = zeros(W,Ns) # r[q] total weight added to d[q] since last time q was extracted from S
  d[s], r[s] = one(W), one(W)
  S = Queue{D}()
  enqueue!(S,s)
  while !isempty(S)
    q = dequeue!(S) 
    R = r[q]
    r[q] =  zero(W)
    for arc in fst[q]
      if filter(arc)
        n, w = get_nextstate(arc), get_weight(arc)
        dn = d[n]
        if dn != (dn+(R*w))
          d[n] = dn+(R*w) 
          r[n] = r[n]+(R*w)
          if !(n in S)
            enqueue!(S,n)
          end
        end
      end
    end
  end
  d[s] = one(W)
  return d
end

