# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export wfst2tr
"""
  `wfst2tr(fst,Nt; get_label=get_ilabel)`

Returns an array `time2tr` of length `Nt-1`.
The `t`-th element of `time2tr` is a dictionary mapping the transition index between input label at time `t` to the input label at time `t+1`.

```julia
julia> using FiniteStateTransducers

julia> H = WFST(["a1","a2","a3"],["a"]);

julia> add_arc!(H,1,2,"a1","a");

julia> add_arc!(H,2,3,"a2","<eps>");

julia> add_arc!(H,2,2,"a2","<eps>");

julia> add_arc!(H,3,4,"a3","<eps>");

julia> add_arc!(H,3,2,"a3","a");

julia> initial!(H,1);

julia> final!(H,4)
WFST #states: 4, #arcs: 5, #isym: 3, #osym: 1
|1/0.0f0|
a1:a/0.0f0 → (2)
(2)
a2:ϵ/0.0f0 → (3)
a2:ϵ/0.0f0 → (2)
(3)
a3:ϵ/0.0f0 → (4)
a3:a/0.0f0 → (2)
((4/0.0f0))


julia> Nt = 10;

julia> time2tr = wfst2tr(H,Nt)
9-element Array{Dict{Int64,Array{Int64,1}},1}:
 Dict(1 => [2])
 Dict(2 => [2, 3])
 Dict(2 => [2, 3],3 => [2])
 Dict(2 => [2, 3],3 => [2])
 Dict(2 => [2, 3],3 => [2])
 Dict(2 => [2, 3],3 => [2])
 Dict(2 => [2, 3],3 => [2])
 Dict(2 => [2],3 => [2])
 Dict(2 => [3])

```

"""
function wfst2tr(fst::WFST{W,A,D},Nt; get_label=get_ilabel) where {W,A,D}
  isym=get_isym(fst)
  Ns = length(isym)
  X = matrix2wfst(isym,ones(W,Ns,Nt); W = W)

  Z = ∘(X,fst; connect=true)

  i = get_initial(Z)
  current_states = Set{D}([i])
  next_states = Set{D}()
  time2transitions = [Dict{D,Vector{D}}() for t in 1:Nt-1]
  t = 1
  while !isempty(current_states)
    dict = Dict{D,Set{D}}()
    for c in current_states
      for c_arc in Z[c]
        src = D(get_label(c_arc))
        n = get_nextstate(c_arc)
        push!(next_states,n)
        dest = Set{D}([D(get_label(n_arc)) for n_arc in Z[n]])
        if !isempty(dest)
          if haskey(dict,src)
            union!(dict[src],dest)
          else
            dict[src] = dest
          end
        end
      end
    end
    if t < Nt
      time2transitions[t] = Dict(k=>[dict[k]...] for k in keys(dict))
    else
      if !isempty(dict)
        error("something is wrong with the graph")
      end
    end
    t += 1
    current_states, next_states = next_states, Set{D}()
  end
  return time2transitions
end

"""
  `wfst2tr(fst; get_label=get_ilabel, convert_weight=identity)`

Extract transition matrix and initial probabilities from a WFST representing an HMM model.

```julia
julia> add_arc!(H,1,2,"a1","a");

julia> add_arc!(H,2,2,"a1","<eps>",-log(0.3));

julia> add_arc!(H,2,3,"a2","<eps>",-log(0.7));

julia> add_arc!(H,3,3,"a2","<eps>",-log(0.3));

julia> add_arc!(H,3,4,"a3","<eps>",-log(0.7));

julia> add_arc!(H,4,4,"a3","<eps>",-log(0.3));

julia> add_arc!(H,4,2,"a1","a",-log(0.7));

julia> initial!(H,1);

julia> final!(H,4)
WFST #states: 4, #arcs: 12, #isym: 3, #osym: 1
|1/0.0f0|
a1:a/0.0f0 → (2)
a1:a/0.0f0 → (2)
(2)
a2:ϵ/0.0f0 → (3)
a2:ϵ/0.0f0 → (2)
a1:ϵ/1.2039728f0 → (2)
a2:ϵ/0.35667494f0 → (3)
(3)
a3:ϵ/0.0f0 → (4)
a3:a/0.0f0 → (2)
a2:ϵ/1.2039728f0 → (3)
a3:ϵ/0.35667494f0 → (4)
((4/0.0f0))
a3:ϵ/1.2039728f0 → (4)
a1:a/0.35667494f0 → (2)

julia> a,A = wfst2tr(H; convert_weight = w -> exp(-get(w)))
(Float32[1.0, 0.0, 0.0], Float32[0.3 0.7 0.0; 0.0 0.3 0.7; 0.7 0.0 0.3])
```
"""
function wfst2tr(fst::WFST{W,A,D}; 
                 get_label=get_ilabel, convert_weight=identity) where {W,A,D}
  isym=get_isym(fst)
  Ns = length(isym)
  W2 = typeof(convert_weight(one(W)))
  a = zeros(W2,Ns)
  H = zeros(W2,Ns,Ns)
  init = get_initial(fst)
  state2outtr = Dict(i => (get_ilabel.(s),get_weight.(s)) for (i,s) in enumerate(fst))
  for (p,s,n,d,e,a) in FiniteStateTransducers.DFS(fst,init)
    if d
      intr = get_ilabel(a)
      outtr, w = state2outtr[n]
      for i in eachindex(outtr)
        H[intr,outtr[i]] = convert_weight(w[i])
      end
    end
  end
  for arc in fst[init]
    a[get_label(arc)] = convert_weight(get_weight(arc))
  end
  return a, H
end
