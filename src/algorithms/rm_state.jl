# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export rm_state!
function rm_state!(fst::WFST, idx)
  # map to new indices with (-1) where rm 
  new_id = zeros(Int,length(fst))
  s = get_states(fst)

  for i in idx
    new_id[i] = -1
    rm_initial!(fst,i)
    rm_final!(fst,i)
  end

  nstates = 0
  # this pushes all states to be removed at the end of s
  for i in eachindex(s)
    if new_id[i] != -1
      nstates += 1  
      new_id[i] = nstates
      if isfinal(fst,i)
        w = get_final_weight(fst,i)
        rm_final!(fst,i)
        final!(fst,nstates,w)
      end
      if isinitial(fst,i)
        w = get_initial_weight(fst,i)
        rm_initial!(fst,i)
        initial!(fst,nstates,w)
      end
      if i != nstates
        s[i], s[nstates] = s[nstates], s[i]
      end
    end
  end
  # remove states
  deleteat!(s,(length(s)-length(idx)+1):length(s))

  # remove arcs and update idx
  for si in s
    to_rm = Int[]
    for (ii, arc) in enumerate(si)
      t = new_id[get_nextstate(arc)]
      if t != -1
        new_arc = change_next(arc,t) 
        si[ii] = new_arc
      else
        push!(to_rm,ii)
      end
    end
    deleteat!(si,to_rm)
  end
end
