# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

function Base.show(io::IO, fst::WFST)
  sz = size(fst)
  println("WFST #states: $(sz[1]), #arcs: $(sz[2]), #isym: $(length(fst.isym)), #osym: $(length(fst.osym))")
  if sz[2] < 100 && !isempty(fst)
    int2isym = get_iisym(fst)
    int2osym = get_iosym(fst)
    for (i,s) in enumerate(fst)
      if isinitial(fst,i) && isfinal(fst,i)
        wi = get_initial_weight(fst,i) 
        wf = get_final_weight(fst,i) 
        println("|(($(i)/$(wi*wf)))|")
      elseif isfinal(fst,i)
        w = get_final_weight(fst,i) 
        println("(($(i)/$(w)))")
      elseif isinitial(fst,i)
        w = get_initial_weight(fst,i) 
        println("|$(i)/$(w)|")
      else
        println("($(i))")
      end
      show_state(io, s, int2isym, int2osym)
    end
  end
end

function show_state(io::IO, s, int2isym, int2osym)
  for arc in s
    show(io, arc, int2isym, int2osym)
    println()
  end
end

function Base.show(io::IO, p::Path)
  if length(p.ilabels) + length(p.olabels) < 50
    isym = get_iisym(p)
    osym = get_iosym(p)
    print(io, "$([isym[i] for i in p.ilabels]) → $([osym[i] for i in p.olabels]), w:$(p.weight)" )
  else
    print(io, " #$(length(p.ilabels)) → #$(length(p.olabels)), w:$(p.weight)" )
  end
end
