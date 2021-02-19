# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export linearfst
"""
`linearfst(ilabels,olabels,w,[isym,[osym=isym]]; W=TropicalWeight{Float32})`

Creates a linear WFST. `ilabels`, `olabels` and `w` are the input labels, output labels and weights respectively which must be vectors of the same size.
If input and output tables `isym` and `osym` are not provided, the symbol tables are derived from `ilabels` and `olabels`.

```julia
julia> A = linearfst([1,1,3,4],[:a,:b,:c,:d],ones(TropicalWeight{Float64},4))
WFST #states: 5, #arcs: 4, #isym: 3, #osym: 4
|1/0.0|
1:a/0.0 → (2)
(2)
1:b/0.0 → (3)
(3)
3:c/0.0 → (4)
(4)
4:d/0.0 → (5)
((5/0.0))

```
"""
function linearfst(ilabels::AbstractVector,
                   olabels::AbstractVector,
                   w::AbstractVector,
                   isym::AbstractDict,
                   osym::AbstractDict=isym; W = TropicalWeight{Float32}
                  )
  N = length(w)
  if !(length(ilabels) == length(olabels) == N)
    throw(ErrorException("`ilabels`, `olabels`, and `w` must have all the same lengths"))
  end
  fst = WFST(isym,osym; W = W)
  for i = 1:N
    add_arc!(fst, i, i+1, ilabels[i], olabels[i], W(w[i]))
  end
  initial!(fst,1)
  final!(fst,length(w)+1)
  return fst
end

linearfst(ilabels,olabels,w) =
linearfst(ilabels,olabels,w,
          Dict(s=>k for (k,s) in enumerate(unique(ilabels) )),
          Dict(s=>k for (k,s) in enumerate(unique(olabels) ))
              )

export matrix2wfst
"""
`matrix2wfst(isym,[osym,] X; W = TropicalWeight{Float32})`

Creates a WFST with weight type `W` and input output tables `isym` and `osym` using the matrix `X`.
If `X` is a matrix of dimensions `Ns`x`Nt`, the resulting WFST will have `Nt+1` states.
Arcs form the `t`-th state of `fst` will go only to the `t+1`-th state and will correspond to the non-zero element of the `t`-th column of `X`.
State `1` and `Nt+1` are labelled as initial and final state, respectively.

```julia
julia> matrix2wfst(["a","b","c"],[1 2 3; 1 2 3; 1 2 3])
WFST #states: 4, #arcs: 9, #isym: 3, #osym: 3
|1/0.0f0|
a:a/1.0f0 → (2)
b:b/1.0f0 → (2)
c:c/1.0f0 → (2)
(2)
a:a/2.0f0 → (3)
b:b/2.0f0 → (3)
c:c/2.0f0 → (3)
(3)
a:a/3.0f0 → (4)
b:b/3.0f0 → (4)
c:c/3.0f0 → (4)
((4/0.0f0))

```
"""
function matrix2wfst(isym::AbstractDict{I,D},
                     osym::AbstractDict{O,D},
                     X::AbstractMatrix; W = TropicalWeight{Float32}) where {D,I,O}
  fst = WFST(isym, osym; W = W)
  Ns, Nt = size(X)
  add_states!(fst,Nt+1)
  for t = 1:Nt, j = 1:Ns
    if W(X[j,t]) != zero(W)
      arc = Arc{W,D}(j,j,W(X[j,t]),t+1)
      push_arc!(fst,t,arc)
    end
  end
  initial!(fst,1)
  final!(fst,Nt+1)
  return fst
end

matrix2wfst(isym,X;kwargs...) = matrix2wfst(isym,isym,X;kwargs...)
matrix2wfst(isym::Vector,osym::Vector,X;kwargs...) =
matrix2wfst(Dict(s=>k for (k,s) in enumerate(unique(isym) )),
            Dict(s=>k for (k,s) in enumerate(unique(osym) )),X; kwargs...)
