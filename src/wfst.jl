# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export WFST

struct WFST{W, A<:Arc{W}, D, I, O, 
            IS <: AbstractDict{I,D}, OS <: AbstractDict{O,D},
            IF <: AbstractDict{D,W},
            S  <: AbstractVector{<:AbstractVector{A}}
           } 
  states::S 
  initials::IF # index of initial state and corresponding weights
  finals::IF   # index of final state and corresponding weights
  isym::IS     # input  symbol table idx::Int => sym::I
  osym::OS     # output symbol table idx::Int => sym::O
end

"""
  `WFST(isym, [osym]; W = TropicalWeight{Float32})`

Construct an empty Weighted Finite State Transducer (WFST)

* `isym` input symbol table (can be a dictionary or a vector)
* `osym` output symbol dictionary (optional)
* `W` weight type

If the symbol table are `AbstractDict{I,D}`, `D` must be an integer and `I` the type of the symbol.
"""
function WFST(isym::Dict{I,D}, osym::Dict{O,D}; W=TropicalWeight{Float32}) where {D<:Integer, I, O}
  A = Arc{W,D}
  states=Vector{Vector{A}}()
  initials=Dict{D,W}() 
  finals=Dict{D,W}()
  WFST(states,initials,finals,isym,osym) 
end

parse_sym(sym::AbstractArray) = Dict(s => i for (i,s) in enumerate(sym))
parse_sym(sym::AbstractDict)  = sym
parse_sym(sym) = throw(ErrorException("Symbol table must be either a Vector or a Dict"))

WFST(isym;kwargs...) = WFST(isym,isym; kwargs...)
WFST(isym,osym;kwargs...) = WFST(parse_sym(isym),parse_sym(osym);kwargs...)

# methods
export add_states!

"""
`add_states!(fst,N)`

Add `N` empty states to the FST.
"""
function add_states!(fst::WFST{W,A}, N::Int) where {W,A}
  s = get_states(fst)
  for i = 1:N
    push!(s, Vector{A}() )
  end
  return fst
end

export get_initial
"""
`get_initial(fst::WFST, [single=false])`

Returns the initial state id of the `fst`. If `single` is `true` the first initial state is returned.
"""
function get_initial(fst::WFST; single=true) 
  if isempty(fst.initials)
    throw(ErrorException("No initial state is present"))
  end
  if single 
    return first(keys(fst.initials))
  else
    return fst.initials
  end
end

export get_initial_weight
"""
`get_initial_weight(fst::WFST,i)`

Returns the weight of initial `i`-th state of `fst`. 
"""
get_initial_weight(fst::WFST,i) = get_initial(fst;single=false)[i]

export isinitial
"""
`isinitial(fst::WFST, i)`

Check if the `i`-th state is an initial state.
"""
isinitial(fst::WFST,i) = i in keys(fst.initials)

export initial!
"""
`initial!(fst::WFST{W},i, [w=one(W)])`

Set the `i`-th state as a initial state. A weight `w` can also be provided.
"""
function initial!(fst::WFST{W}, i, w=one(W)) where {W}
  fst.initials[i] = W(w)
  return fst
end

export rm_initial!
"""
`rm_initial!(fst,i)`

Remove initial state labeling of the state `i`.
"""
rm_initial!(fst,i) = delete!(fst.initials,i)

export get_final
"""
`get_final(fst::WFST, [single=false])`

Returns the final state id of the `fst`. If `single` is `true` the first final state is returned.
"""
function get_final(fst::WFST; single=false) 
  if isempty(fst.finals)
    throw(ErrorException("No final state is present"))
  end
  if single 
    return first(keys(fst.finals))
  else
    return fst.finals
  end
end

export get_final_weight
"""
`get_final_weight(fst::WFST,i)`

Returns the weight of `i`-th final state of `fst`. 
"""
get_final_weight(fst::WFST,i) = get_final(fst;single=false)[i]

export isfinal
"""
`isfinal(fst::WFST, i)`

Check if the `i`-th state is an final state.
"""
isfinal(fst::WFST,i) = i in keys(fst.finals)

export final!
"""
`final!(fst::WFST{W},i, [w=one(W)])`

Set the `i`-th state as a final state. A weight `w` can also be provided.
"""
function final!(fst::WFST{W}, i, w) where {W}
  fst.finals[i] = W(w)
  return fst
end
final!(fst::WFST{W},i) where {W} = final!(fst,i,one(W))

export rm_final!
"""
`rm_final!(fst,i)`

Remove final state labeling of the `i`-th state.
"""
rm_final!(fst::WFST,i) = delete!(fst.finals,i)

export get_states
"""
`get_states(fst::WFST)`

Returns the states the `fst`.
"""
get_states(fst::WFST) = fst.states

export add_arc!
"""
`add_arc!(fst, src, dest, ilabel, olabel[, w=one(W)])`

`add_arc!(fst, srcdest::Pair, ilabelolabel::Pair[, w=one(W)])`

Adds an arc from state `src` to state `dest` with input label `ilabel`, output label `olabel` and weight `w`.
Alternative notation utilizes `Pair`s.

If `w` is not provided this defaults to `one(W)` where `W` is the weight type of `fst`.

"""
function add_arc!(fst::WFST{W}, 
                  srcdest::Pair, 
                  iolabel::Pair, 
                  w=one(W)) where {W}
  src, dest = srcdest.first, srcdest.second
  ilabel, olabel = iolabel.first, iolabel.second
  add_arc!(fst,src,dest,ilabel,olabel,w)
end

function parse_label(label,sym)
  if label in keys(sym)
    idx = sym[label]
  elseif iseps(label)
    idx = 0
  else
    throw(ErrorException("Symbol $label not found in symbol table $sym"))
  end
  return idx
end

function add_arc!(fst::WFST{W,A},
                  src::D,dest::D,
                  ilabel, olabel, w=one(W)) where {W,D<:Integer,A<:Arc{W,D}}
  if max(src,dest) - length(fst) > 0 
    add_states!(fst, max(src,dest) - length(fst) )  # eventually expand states
  end
  i = parse_label(ilabel, fst.isym)
  o = parse_label(olabel, fst.osym)
  arc = Arc{W,D}(i,o,W(w),dest)
  push_arc!(fst, src, arc)
  return fst
end

# Note that this avoids checking if symbol is already present in the fst
function push_arc!(fst::WFST{W,A,D}, src::D, arc::A) where {W,A,D}
  s = get_states(fst)
  push!(s[src], arc)
  return fst
end

count_arcs(fst::WFST) = isempty(get_states(fst)) ? 0 : sum(length(s) for s in get_states(fst))

Base.getindex(fst::WFST, i) = getindex(get_states(fst),i)

Base.iterate(fst::WFST, args...) = iterate(get_states(fst), args...)

Base.isempty(fst::WFST) = isempty(get_states(fst))

struct ArcIterator
  fst::WFST
end

function Base.iterate(iter::ArcIterator, it_st=(1,1))
  i, j = it_st     # state id, arc id
  s = get_states(iter.fst)[i]
  if j > length(s) 
    while true
      i += 1 # next state
      if i > length(iter.fst) return nothing; end
      s = get_states(iter.fst)[i]
      if !isempty(s) break; end
    end
    j = 1  # reinit arc
  end
  return s[j], (i,j+1)
end

Base.length(iter::ArcIterator) = count_arcs(iter.fst)

export get_arcs
"""
`get_arcs(fst::WFST) = ArcIterator(fst)`

Returns an iterator that can be used to loop through all of the arcs of `fst`.
"""
get_arcs(fst::WFST) = ArcIterator(fst) 

export get_weight
"""
`get_weight(fst::WFST,i)`

Returns the weight of the `i`-th state of `fst`. If there is no weight `nothing` is returned.
"""
function get_weight(fst::WFST,i)
  if isinitial(fst,i)
    return get_initial_weight(fst,i)
  elseif isfinal(fst,i)
    return get_final_weight(fst,i)
  else 
    return nothing
  end
end

# arc inspectors
function get_ilabel(fst::WFST{W,A,D},s::D,a::D) where {W,A,D}
  return get_iisym(fst)[get_ilabel(fst[s][a])]
end
function get_olabel(fst::WFST{W,A,D},s::D,a::D) where {W,A,D}
  return get_iosym(fst)[get_olabel(fst[s][a])]
end

function (fst::WFST{W,A,D,I,O})(labels::Vector{I}) where {W,A,D,I,O}
  i = get_initial(fst)
  w = get_initial_weight(fst,i)
  olabels = Vector{O}()
  isym = get_isym(fst)
  osym = get_iosym(fst)
  cnt = 1
  while cnt <= length(labels)
    n = 0
    lab = labels[cnt]
    if iseps(lab)
      cnt += 1
    else
      for arc in fst[i]
        ilab = get_ilabel(arc)
        if ilab == isym[lab] || iseps(ilab)
          if !iseps(ilab) 
            cnt += 1
          end
          olab = get_olabel(arc)
          if !iseps(olab)
            push!(olabels,osym[olab])
          end
          n = get_nextstate(arc)
          w *= get_weight(arc)
          break
        end
      end
      if n == 0 # there is no state with lab
        w = zero(W)
        break
      else
        i = n
      end
    end
  end

  # finished labels but there could still be ilab == ϵ
  while !isfinal(fst,i)
    n = 0
    for arc in fst[i]
      ilab = get_ilabel(arc)
      olab = get_olabel(arc)
      if iseps(ilab)
        if !iseps(olab)
          push!(olabels,osym[olab])
        end
        n = get_nextstate(arc)
        w *= get_weight(arc)
        break
      end
    end
    if n == 0 # there is no state with lab
      w = zero(W)
      break
    else
      i = n
    end
  end

  if isfinal(fst,i) 
    w *= get_final_weight(fst,i)
  else
    w = zero(W)
  end
  return olabels, w
end
