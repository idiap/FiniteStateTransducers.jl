# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export determinize_fsa
"""
  `determinize_fsa(fsa)`

Returns a deterministic finite state acceptor. `fsa` must be an acceptor ([`is_acceptor`](@ref)).

Requires the WFST to be defined in a left distributive and weakly divisible semiring.

See [M. Mohri, F. Pereira, Fernando, M. Riley, Michael "Speech Recognition with Weighted Finite-State Transducers" in Springer Handb. Speech Process. 2008](https://cs.nyu.edu/~mohri/pub/hbka.pdf) for details.
"""
function determinize_fsa(fst::WFST{W,A,D,I,O}) where {W,A,D,I,O}
  if !isleft(W)
    throw(ErrorException("Semiring $W is not left distributive, fst cannot be determinized."))
  end
  if !isweaklydivisible(W)
    throw(ErrorException("Semiring $W is not weakly divisible, fst cannot be determinized."))
  end
  dfst = WFST(get_isym(fst), get_osym(fst); W = W)
  i = get_initial(fst)
  w = get_initial_weight(fst,i)
  initial!(dfst,get_initial(fst))

  S = Queue{Set{Tuple{D,W}}}()
  qq = Set([(i,w)])
  cnt = 1
  qq2state = Dict( qq => cnt ) # new states
  enqueue!(S,qq)
  while !isempty(S)
    pp = dequeue!(S)
    lab2weight = Dict{D,W}() # set in line 8 of Fig.10 in [1]
    lab_nextstate2weight = Dict{D,Dict{D,W}}() # set in line 9 of Fig.10 in [1]

    for (p,v) in pp
      for arc in fst[p]
        lab, w, n = get_ilabel(arc), get_weight(arc), get_nextstate(arc)
        vw = v*w
        if get_ilabel(arc) in keys(lab2weight)
          lab2weight[lab] +=  vw 
        else
          lab2weight[lab]  =  vw 
        end
        if lab in keys(lab_nextstate2weight)
          if n in keys(lab_nextstate2weight[lab])
            lab_nextstate2weight[lab][n] += vw
          else
            lab_nextstate2weight[lab][n] = vw
          end
        else
          lab_nextstate2weight[lab] = Dict(n => vw)
        end
      end
    end

    for lab in keys(lab2weight)
      qq = Set{Tuple{D,W}}()
      wp = lab2weight[lab]
      for n in keys(lab_nextstate2weight[lab])
        vw = lab_nextstate2weight[lab][n]
        push!(qq,(n, one(W) / wp * vw))
      end
      if !(qq in keys(qq2state))
        cnt += 1
        qq2state[qq] = cnt
        src, dest = qq2state[pp], cnt
        if max(src,dest) - length(dfst) > 0 
          add_states!(dfst, max(src,dest) - length(dfst) )  # expand states
        end
        push!(dfst[src],Arc{W,D}(lab,lab,wp,dest))
        rho = zero(W)
        any_final = false
        for (n,v) in qq
          if isfinal(fst,n)
            any_final = true
            rho += v*get_final_weight(fst,n) 
          end
        end
        if any_final final!(dfst,cnt,rho) end
        enqueue!(S,qq)
      else
        src, dest = qq2state[pp], qq2state[qq]
        push!(dfst[src],Arc{W,D}(lab,lab,wp,dest))
      end
    end
  end
  return dfst
end
