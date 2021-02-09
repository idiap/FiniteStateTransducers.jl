# [Weights](@id weights)

The weights of WFSTs typically belong to particular [semirings](https://en.wikipedia.org/wiki/Semiring).
The two binary operations ``\oplus`` and ``\otimes`` are exported as `+` and `*`.
The null element ``\bar{0}`` and unity element ``\bar{1}`` can be obtained using the functions `zero(W)` and `one(W)` where `W<:Semiring`.

## Semirings

```@docs
ProbabilityWeight
LogWeight
NLogWeight
TropicalWeight
BoolWeight
LeftStringWeight
RightStringWeight
ProductWeight
```

Use `get` to extract the contained object by the semiring:
```julia
julia> w = TropicalWeight{Float32}(2.3)
2.3f0

julia> typeof(w), typeof(get(w))
(TropicalWeight{Float32}, Float32)

```

## Semiring properties

Some algorithms are only available for WFST's whose weights belong to semirings that satisfies certain properties.
A list of these properties follows:

```@docs
FiniteStateTransducers.iscommulative
FiniteStateTransducers.isleft
FiniteStateTransducers.isright
FiniteStateTransducers.isweaklydivisible
FiniteStateTransducers.ispath
FiniteStateTransducers.isidempotent
```
Notice that these functions are not exported by the package.
