# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export Path

mutable struct Path{W,D <: Integer,I,O,
                    IS <: AbstractDict{I,D}, OS <: AbstractDict{O,D}}
  ilabels::Vector{D} # here we only use Int 
  olabels::Vector{D}
  weight::W
  isym::IS     # input  symbol table idx::Int => sym::I
  osym::OS     # output symbol table idx::Int => sym::O
end

"""
  `Path(isym[,osym], iolabel::Pair, w=one(TropicalWeight{Float32}))`

Construct a path with input and output symbol table `isym` and (optional) `osym` (see [`WFST`](@ref)).

`iolabel` is a `Pair` of vectors.

```julia
julia> isym = ["a","b","c","d"];

julia> osym = ["α","β","γ","δ"];

julia> W = ProbabilityWeight{Float32};

julia> p = Path(isym,osym,["a","b","c"] => ["α","β","γ"], one(W))
["a", "b", "c"] → ["α", "β", "γ"], w:1.0f0

```

The weight of a path of a WFST results from the multiplication (``\\otimes``) of the weights of the different arcs that are transversed. See e.g. [`get_paths`](@ref) to extract paths from a WFST.

```julia
julia> p * Path(isym,osym,["d"] => ["δ"], W(0.5))
["a", "b", "c", "d"] → ["α", "β", "γ", "δ"], w:0.5f0

```

"""
function Path(isym::Dict, osym::Dict, iolabels::Pair, w = one(TropicalWeight{Float32}))
  Path([isym[s] for s in iolabels.first], 
       [osym[s] for s in iolabels.second], w, isym, osym)
end
Path(isym, iolabels::Pair, w = one(TropicalWeight{Float32})) = 
Path(isym, isym, iolabels, w)

Path(isym::AbstractVector, osym::AbstractVector, iolabels::Pair, w) = 
Path(
     Dict( s => i for (i,s) in enumerate(isym)),
     Dict( s => i for (i,s) in enumerate(osym)),
     iolabels,w)

get_weight(p::Path) = p.weight
get_ilabel(p::Path) = p.ilabels
get_olabel(p::Path) = p.olabels

export get_isequence
"""
  `get_isequence(p::Path)`

Returns the input sequence of the path `p`.
"""
function get_isequence(p::Path)
  idx2sym = get_iisym(p)
  return [idx2sym[idx] for idx in get_ilabel(p)]
end

export get_osequence
"""
  `get_osequence(p::Path)`

Returns the output sequence of the path `p`.
"""
function get_osequence(p::Path)
  idx2sym = get_iosym(p)
  return [idx2sym[idx] for idx in get_olabel(p)]
end

function update_path!(path::Path{W,D}, ilabel::D, olabel::D, w) where {W,D}
  if !iseps(ilabel)
    push!(path.ilabels, ilabel)
  end
  if !iseps(olabel)
    push!(path.olabels, olabel)
  end
  update_weight!(path, W(w))
  return path
end
function update_path(path,ilabel,olabel,w)
  p = deepcopy(path)
  update_path!(p,ilabel,olabel,w)
  return p
end
update_weight!(path::Path{W}, w::W) where {W} = path.weight *= w
update_weight(path::Path{W}, w::W) where {W} =
Path(path.ilabels,path.olabels,w*path.weight,path.isym,path.osym)

import Base: *

function *(p1::Path, p2::Path)
  Path([p1.ilabels; p2.ilabels], [p1.olabels;p2.olabels], p1.weight*p2.weight, p1.isym, p1.osym)
end

import Base: ==
function ==(p1::Path,p2::Path)
  if (length(p1.ilabels) == length(p2.ilabels)) &&
    (length(p1.olabels) == length(p2.olabels))
    return all(p1.ilabels .== p2.ilabels) && all(p1.olabels .== p2.olabels) && (p1.weight == p2.weight)
  else
    return false
  end
end
