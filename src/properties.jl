# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export typeofweight
"""
`typeofweight(fst_or_path)`

Returns the weight type of a WFST or a path.
"""
typeofweight(fst::Union{WFST{W},Path{W}}) where {W} = W

export get_ialphabet
"""
`get_ialphabet(label::fst)`

Returns the alphabet of the input labels of `fst`.
The alphabet is defined as the set of symbols composing the input or output labels.
"""
get_ialphabet(fst::WFST) = Set(keys(get_isym(fst)))

export get_oalphabet
"""
`get_oalphabet(label::fst)`

Returns the alphabet of the output labels of `fst`.
The alphabet is defined as the set of symbols composing the input or output labels.
"""
get_oalphabet(fst::WFST) = Set(keys(get_osym(fst)))

export count_eps
"""
`count_eps(label::Function, fst::FST)`

Returns number of epsilon transition of either input or output labels.
To specify input or output plug in `ilabel` and `olabel` respectively in `label`. 
"""
function count_eps(label::Function, fst::WFST)
  cnt = 0
  for state in fst 
    for arc in state
      if iseps(label(arc))
        cnt += 1
      end
    end
  end
  return cnt
end

export has_eps
"""
`has_eps([label::Function,] fst::FST)`

Check if `fst` has epsilon transition in either input or output labels.
To specify input or output plug in either `get_ilabel` or `get_olabel` respectively in `label`. 
"""
function has_eps(label::Function, fst::WFST)
  for state in fst 
    for arc in state
      if iseps(label(arc))
        return true
      end
    end
  end
  return false
end

function has_eps(fst::WFST)
  for state in fst 
    for arc in state
      if iseps(get_ilabel(arc))
        return true
      end
      if iseps(get_olabel(arc))
        return true
      end
    end
  end
  return false
end

export is_acceptor
"""
`is_acceptor(fst::WFST)`

Returns `true` if `fst` is an acceptor, i.e. if all arcs have equal input and output labels.
"""
function is_acceptor(fst::WFST) 
  acceptor = true 
  for s in fst
    for a in s
      acceptor = acceptor && (get_ilabel(a) == get_olabel(a))
      if acceptor == false
        break
      end
    end
  end
  return acceptor
end

export is_deterministic
"""
`is_deterministic(fst::WFST; get_label=get_ilabel)`

Returns `true` if `fst` is deterministic in the input labels.
A input label deterministic WFST must have a single initial state and arcs leaving any state do not share the same input label.

Change the keyword `get_label` to `get_olabel` in order to check determinism in the output labels.
"""
function is_deterministic(fst::WFST; get_label=get_ilabel) 
  if length(get_initial(fst; single=false)) > 1
    return false
  end
  for s in fst
    for i in 1:length(s)
      for ii in i+1:length(s)
        if get_label(s[i]) == get_label(s[ii])
          return false
        end
      end
    end
  end
  return true
end

export is_acyclic
"""
  `is_acyclic(fst::WFST[,i = get_initial(fst;single=true)]; kwargs...)`

Returns the number of states of the fst. For `kwargs` see [`DFS`](@ref).
"""
function is_acyclic(fst::WFST, i = get_initial(fst;single=true); kwargs...)
  if isempty(fst)
    return true
  else
    dfs = DFS(fst,i; kwargs...)

    for (p,s,n,d,e,a) in dfs
      if !d # already discovered states
        if !e && !dfs.is_completed[n]
          return false
        end
      end
    end
    return true
  end
end

"""
`length(fst::WFST)`

Returns the number of states of the fst.
"""
Base.length(fst::WFST) = length(get_states(fst))

"""
`size(fst::WFST,[i])`

Returns number of states and total number of arcs in a tuple.
If 'i=1' returns the number of states and if `i=2` the number of arcs. 
"""
Base.size(fst::WFST) = (length(get_states(fst)), count_arcs(fst))
Base.size(fst::WFST,i::Int) = size(fst)[i]
