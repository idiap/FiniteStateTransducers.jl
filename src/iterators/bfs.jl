# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# Breadth-first search 
export BFS
"""
  `BFS(fst,initial)`

Returns an iterator that performs a breadth-first search (BFS) of `fst` starting from the state `initial`.

At each iteartion the tuple `(i,p)` is returned, where `i` is the current state and `p` a [`Path`](@ref).
"""
struct BFS{W,A,D,F <: WFST{W,A,D}}
  fst::F
  initial::D
  function BFS(fst::F,initial::D) where {W,A,D,F <: WFST{W,A,D}}
    if initial==0
      throw(ErrorException("Invalid initial state"))
    end
    new{W,A,D,F}(fst,initial)
  end
end

function init_bfs(fst::WFST{W,A,D}, initial::D) where {W,D,A<:Arc{W,D}}
  q = Queue{Tuple{D,Path{W,D}}}()
  isym = get_isym(fst)
  osym = get_osym(fst)
  w = get_initial_weight(fst,initial)
  p = Path(Vector{D}(), Vector{D}(), w, isym, osym)
  enqueue!(q, (initial, p))
  return q
end

function Base.iterate(it::BFS,
                      q = init_bfs(it.fst,it.initial))
  if isempty(q)
    return nothing
  else
    i, p = dequeue!(q)
    s = it.fst[i]
    for arc in s
      p_new = update_path(p, get_ilabel(arc), get_olabel(arc), get_weight(arc))
      enqueue!(q, (get_nextstate(arc), p_new))
    end
    return (i,p), q
  end
end
