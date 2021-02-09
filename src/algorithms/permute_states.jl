# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

function permute_states(fst::WFST{W,A,D},perm::Vector{D}) where {W,A,D,I}
  if length(perm) != length(fst)
    throw(ErrorException("Number of states of WFST $(lenth(fst)) not equal to permutation length  $(length(perm))"))
  end
  isym=get_isym(fst)
  osym=get_osym(fst)
  iperm = invperm(perm)
  initials = Dict(iperm[k] => fst.initials[k] for k in keys(fst.initials))
  finals = Dict(iperm[k] => fst.finals[k] for k in keys(fst.finals))
  states = [Vector{A}() for i in 1:size(fst,1)]
  for (j,i) in enumerate(perm)
    for arc in fst[i]
      push!(states[j],
            Arc{W,D}(get_ilabel(arc),get_olabel(arc),
                     get_weight(arc),iperm[get_nextstate(arc)])
           )
    end
  end
  return WFST(states,initials,finals,isym,osym)
end
