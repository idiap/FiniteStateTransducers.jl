# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export linearfst
"""
`linearfst(ilabels,olabels,w,isym,[osym])`

Creates a linear WFST. `ilabels`, `olabels` and `w` are the input labels, output labels and weights respectively which must be vectors of the same size. 
Keyword arguments are the same of `WFST` constructor.
"""
function linearfst(ilabels::AbstractVector, 
                   olabels::AbstractVector,
                   w::AbstractVector{W}, 
                   isym::AbstractDict, 
                   osym::AbstractDict) where {W}
  N = length(w)
  if !(length(ilabels) == length(olabels) == N)
    throw(ErrorException("`ilabels`, `olabels`, and `w` must have all the same lengths"))
  end
  fst = WFST(isym,osym; W = W)
  for i = 1:N
    add_arc!(fst, i, i+1, ilabels[i], olabels[i], w[i])
  end
  initial!(fst,1)
  final!(fst,length(w)+1)
  return fst
end

linearfst(ilabels,olabels,w,isym) = 
linearfst(ilabels,olabels,w,isym,isym)

export matrix2wfst
"""
`matrix2wfst(isym,[osym,] X; W = TropicalWeight{Float32})`

Creates a WFST with weight type `W` and input output tables `isym` and `osym` using the matrix `X`.
If `X` is a matrix of dimensions `Ns`x`Nt`, the resulting fst will have `Nt+1` states.
Arcs form the `t`-th state of `fst` will go only to the `t+1`-th state and will correspond to the non-zero element of the `t`-th column of `X`. 
State `1` and `Nt+1` are initial and final state, respectively.
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
