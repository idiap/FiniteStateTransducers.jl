# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export get_scc
"""
  `get_scc(fst::WFST, i = get_initial(fst;single=true); filter=arc->true)`

Calculates the strongly connected components of 'fst' using Tarjan's algorithm.
Returns a tuple `(scc,c,v)`:
  * `scc` are the strongly connected components of `fst`
  * `c` is a boolean array containing the accessibility form the `i`
  * `v` are the visited states of the `fst`
The function `filter` can be used to consider only arcs with specific properties.
"""
function get_scc(fst::WFST, i = get_initial(fst;single=true); kwargs...)
  if isempty(fst)
    return Bool[]
  else
    stack=Int[]
    sccs=Vector{Vector{Int}}()
    lowlink=zeros(Int,size(fst,1))
    order=zeros(Int,size(fst,1))
    onstack=zeros(Bool,size(fst,1))
    coaccess=zeros(Bool,size(fst,1))

    dfs = DFS(fst,i; kwargs...)
    cnt = 1
    lowlink[1] = cnt
    order[1] = cnt
    onstack[1] = true
    push!(stack,i)

    for (p,s,n,d,e,a) in dfs
      if d # discovering new nodes
        cnt +=1
        lowlink[n] = cnt
        order[n] = cnt
        onstack[n] = true
        push!(stack,n)
      else 
        if e # state explored
          if isfinal(fst,s)
            coaccess[s] = true
          end
          if lowlink[s] == order[s]
            scc = Vector{Int}()
            c_coaccess = false
            a = 0
            while a != s
              a = pop!(stack)
              onstack[a] = false
              if coaccess[a] c_coaccess = true end
              push!(scc,a)
            end
            if c_coaccess
              for z in scc coaccess[s] = true end
            end
            reverse!(scc)
            push!(sccs,scc)
          end
          if p != 0 
            lowlink[p] = min(lowlink[p],lowlink[s])
            if coaccess[s] coaccess[p] = true end
          end
        else
          # n already visited
          lowlink[s] = min(order[n],lowlink[s])
          if coaccess[n] coaccess[s] = true end
        end
      end
    end
    reverse!(sccs)
    return sccs, coaccess, dfs.is_visited
  end
end
