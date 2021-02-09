# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export is_visited
"""
  `is_visited(fst::WFST, i = get_initial(fst;single=true))`

Return an array of booleans indicating if the i-th state of the fst is visted starting form `i`.
"""
function is_visited(fst::WFST, i = get_initial(fst;single=true))
  if isempty(fst)
    return Bool[]
  else
    d = DFS(fst,i)
    for i in d 
      nothing
    end
    return d.is_visited 
  end
end
