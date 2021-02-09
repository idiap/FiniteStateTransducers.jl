# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export arcmap
"""
`arcmap(f::Function, fst::WFST, args...; modify_initials=identity, modify_finals=identity, isym=get_isym(fst), osym=get_osym(fst))`

Creates a new WFST from `fst` by applying the function `f` to all its arcs, see [`Arc`](@ref). 
The arguments of `f` can be specified in `args`.

The functions `modify_initials` and `modify_finals` operate in the initial and final dictionaries, which keys are the initial/final states and values are the corresponding state weights.

Input and output tables can also be modified using the keywords `isym` and `osym`.

The following example shows how to use `arcmap` to convert the type of weight of a WFST:
```julia
julia> A = WFST(["a","b","c"]); # by default weight is TropicalWeight{Float32}

julia> add_arc!(A,1=>2,"a"=>"a",1);

julia> add_arc!(A,1=>3,"b"=>"c",3);

julia> initial!(A,1); final!(A,2,4); final!(A,3,2)
WFST #states: 3, #arcs: 2, #isym: 3, #osym: 3
|1/0.0f0|
a:a/3.0f0 → (2)
b:c/3.0f0 → (3)
((2/4.0f0))
((3/2.0f0))

julia> trop2prob(x) = ProbabilityWeight{Float64}(exp(-get(x)))
trop2prob (generic function with 1 method)

julia> function trop2prob(arc::Arc)
           ilab = get_ilabel(arc)
           olab = get_olabel(arc)
           w = trop2prob(get_weight(arc))
           n = get_nextstate(arc)
           return Arc(ilab,olab,w,n)
       end
trop2prob (generic function with 2 methods)

julia> trop2prob(initials::Dict) = Dict(i => trop2prob(w) for (i,w) in initials)
trop2prob (generic function with 3 methods)

julia> arcmap(trop2prob,A; modify_initials=trop2prob, modify_finals=trop2prob)
WFST #states: 3, #arcs: 2, #isym: 3, #osym: 3
|1/1.0|
a:a/0.3678794503211975 → (2)
b:c/0.049787066876888275 → (3)
((2/0.018315639346837997))
((3/0.1353352814912796))

```
"""
function arcmap(f::Function, fst::WFST, args...;
                modify_initials = identity,
                modify_finals = identity,
                isym = get_isym(fst),
                osym = get_osym(fst)
               )
  states = [f.(arcs, args...) for arcs in get_states(fst)]
  finals   = modify_finals(  deepcopy(fst.finals)  )
  initials = modify_initials(deepcopy(fst.initials))
  osym = deepcopy(fst.osym)
  isym = deepcopy(fst.isym)
  pfst = WFST(states,initials,finals,isym,osym)
  return pfst
end
