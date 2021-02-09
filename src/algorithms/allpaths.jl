# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export get_paths, collectpaths

struct PathIterator{W,A,D,F}
  bfs::BFS{W,A,D,F}
end

"""
  `get_paths(fst::FST, [i = get_initial(fst;single=true)])`

Returns an iterator that generates all of the possible paths of `fst` starting from `i`.

Notice that the `fst` must be acyclic for the algorithm to stop (see [`is_acyclic`](@ref)).
"""
get_paths(fst::WFST, i=get_initial(fst;single=true)) = PathIterator(BFS(fst,i))

function Base.iterate(it::PathIterator, q=init_bfs(it.bfs.fst, it.bfs.initial))
  if isempty(q)
    return nothing
  else
    while true
      (i,p), q = iterate(it.bfs,q)
      if isfinal(it.bfs.fst,i)
        w = get_final_weight(it.bfs.fst,i)
        pf = update_weight(p,w)
        return pf, q
      end
    end
  end
end

"""
  `collectpaths(fst::FST, [i = get_initial(fst;first=true)])`

Returns an array containing all of the possible paths of `fst` starting from `i`.

Notice that the `fst` must be acyclic for the algorithm to stop (see [`is_acyclic`](@ref)).
"""
function collectpaths(fst::WFST{W,A,D,I,O}, 
                      i::D=get_initial(fst;single=true)) where {W,D,I,O, 
                                                                  A <: Arc{W,D}}
  paths = Vector{Path{W,D}}()
  if !isempty(fst)
    pathsIt = BFS(fst, i)
    for (i,p) in pathsIt
      if isfinal(fst,i)
        w = get_final_weight(fst,i)
        pf = update_weight(p,w)
        push!(paths,pf)
      end
    end
  end
  return paths
end
