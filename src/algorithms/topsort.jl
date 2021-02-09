# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export topsortperm
"""
  `topsortperm(fst::WFST, i = get_initial(fst); filter=arc->true)`

Requires `fst` to be acyclic.

Returns the topological permutation of states of `fst` starting from the `i`-th state.

Modify the `filter` function to perform the operation considering only specific arcs.

"""
function topsortperm(fst::WFST, i = get_initial(fst;single=true); kwargs...)
  if isempty(fst)
    return Bool[]
  else
    perm=zeros(Int,size(fst,1))
    acyclic=true
    perm[1] = i
    cnt = 2

    dfs = DFS(fst,i; kwargs...)

    for (p,s,n,d,e,a) in dfs
      if d # discovering new nodes
        perm[cnt] = n
        cnt += 1
      else
        if !e && !dfs.is_completed[n]
          throw(ErrorException("Topological sort failed, fst is not acyclic"))
        end
      end
    end
    return perm
  end
end

export topsort
"""
  `topsort(fst::WFST, i = get_initial(fst); filter=arc->true)`

Requires `fst` to be acyclic.

Returns an equivalent WFST to `fst` which is topologically sorted starting from the `i`-th state.

Modify the `filter` function to perform the operation considering only specific arcs.

"""
function topsort(fst::WFST, i = get_initial(fst;single=true); kwargs...)
  perm = topsortperm(fst,i;kwargs...)
  return permute_states(fst,perm)
end
