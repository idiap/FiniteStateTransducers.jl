# [Introduction](@id intro)

## Weighted Finite State Transducers

Weighted finite state transducers (WFSTs) are graphs capable of translating an input sequence of symbols to an output sequence of symbols and associate a particular weight to this conversion. 

Firstly we define the input and output symbols:
```julia
julia> isym = [s for s in "hello"];

julia> osym = [s for s in "world"];

```

We can construct a WFST by adding arcs, where each arc has an input label, an output label and a weight (which is typically defined in a particular [semiring](@ref weights)):
```julia
julia> using FiniteStateTransducers

julia> W = ProbabilityWeight{Float64} # weight type

julia> A = WFST(isym,osym; W=W); # empty wfst

julia> add_arc!(A,1=>2,'h'=>'w',1); # arc from state 1 to 2 with in label 'h' and out label 'w' and weight 1

julia> add_arc!(A,2=>3,'e'=>'o',1); # arc from state 2 to 3 with in label 'e' and out label 'w' and weight 0.5

julia> add_arc!(A,3=>4,'l'=>'r',1);

julia> add_arc!(A,4=>5,'l'=>'l',1); 

julia> add_arc!(A,5=>6,'o'=>'d',1);

julia> initial!(A,1); final!(A,6) # set initial and final state
WFST #states: 6, #arcs: 5, #isym: 4, #osym: 5
|1/1.0|
h:w/1.0 → (2)
(2)
e:o/1.0 → (3)
(3)
l:r/1.0 → (4)
(4)
l:l/1.0 → (5)
(5)
o:d/1.0 → (6)
((6/1.0))

```
We can now plug the input sequence `['h','e','l','l','o']` into the WFST:
```julia
julia> A(['h','e','l','l','o'])
(['w', 'o', 'r', 'l', 'd'], 1.0)

```
The input sequence is translated into `['w', 'o', 'r', 'l', 'd']`  with probability `1.0`.
A sequence that cannot be accepted will return a null probability instead:
```julia
julia> A(['h','e','l','l'])
(['w', 'o', 'r', 'l'], 0.0)

```
We could modify the WFST by adding an arc with an epsilon label, which is special symbol ϵ that can be skipped (see Sec. [Epsilon label](@ref) for more info):
```julia
julia> add_arc!(A,5=>6,'ϵ'=>'d',0.001);

julia> A(['h','e','l','l'])
(['w', 'o', 'r', 'l', 'd'], 0.001)

```
Here we used a small probability for this epsilon arc and this results in a low probability of the transduced output sequence.
In fact the resulting probability of a sequence is the product of the weights of the arcs that were accessed (see [Paths](@ref)).

!!! note

    The method `(transduce::WFST)(ilabels::Vector)` transduce the sequence of `ilabel` using the WFST `fst` requires the WFST to be input deterministic, see [`is_deterministic`](@ref).

See [[1]](@ref references) for a good tutorial on WFST with the focus on speech recognition. 

## [References](@id references)

- [1] [Mohri, Mehryar and Pereira, Fernando and Riley, Michael, "Speech Recognition with Weighted Finite-State Transducers," Springer Handb. Speech Process. 2008](http://www.openfst.org/twiki/pub/FST/FstBackground/hbka.pdf)
