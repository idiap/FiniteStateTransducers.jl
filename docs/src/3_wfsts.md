# WFSTs internals

## Formal definition 

Formally a WFSTs over the semiring ``\mathbb{W}`` is the tuple ``(\mathcal{A},\mathcal{B},Q,I,F,E,\lambda,\rho)`` where:
* ``\mathcal{A}`` is the input alphabet (set of input labels)
* ``\mathcal{B}`` is the output alphabet (set of output labels)
* ``Q`` is a set of states (usually integers)
* ``I \subseteq Q`` is the set of initial states
* ``F \subseteq Q`` is the set of final states
* ``E \subseteq Q \times \mathcal{A} \cup \{ \epsilon \} \times \mathcal{B} \cup \{ \epsilon \} \times \mathbb{W} \times Q`` is a set of arcs (transitions) where an element consist of the tuple (starting state,input label, output label, weigth, destination state)
* ``\lambda : I \rightarrow \mathbb{W}`` a function that maps initial states to a weight 
* ``\rho : F \rightarrow \mathbb{W}`` a function that maps final states to a weight 

## Constructors and modifiers

```@docs
WFST
add_arc!
add_states!
initial!
final!
rm_final!
rm_initial!
```

## Internal access

```@docs
get_isym
get_iisym
get_osym
get_iosym
get_states
get_initial
get_initial_weight
get_final
get_final_weight
get_ialphabet
get_oalphabet
get_arcs
```

## Arcs
```@docs
Arc
get_ilabel
get_olabel
get_weight
get_nextstate
```

## Paths

```@docs
Path
get_isequence
get_osequence
```

## Tour of the internals

Let's build a simple WFST and check out its internals: 
```julia
julia> using FiniteStateTransducers

julia> A = WFST(["hello","world"],[:ciao,:mondo]);

julia> add_arc!(A,1=>2,"hello"=>:ciao);

julia> add_arc!(A,1=>3,"world"=>:mondo);

julia> add_arc!(A,2=>3,"world"=>:mondo);

julia> initial!(A,1);

julia> final!(A,3)
WFST #states: 3, #arcs: 3, #isym: 2, #osym: 2
|1/0.0f0|
hello:ciao/0.0f0 → (2)
world:mondo/0.0f0 → (3)
(2)
world:mondo/0.0f0 → (3)
((3/0.0f0))

```

For this simple WFST the states consists of an `Array` of `Array`s containing `Arc`:
```julia
julia> get_states(A)
3-element Array{Array{FiniteStateTransducers.Arc{TropicalWeight{Float32},Int64},1},1}:
 [1:1/0.0f0 → (2), 2:2/0.0f0 → (3)]
 [2:2/0.0f0 → (3)]
 []
```
As it can be seen the first state has two arcs, second state only one and the final state none.
A state can also be accessed as follows:
```julia
julia> A[2]
1-element Array{FiniteStateTransducers.Arc{TropicalWeight{Float32},Int64},1}:
 2:2/0.0f0 → (3)
```
Here the arc's input/output labels are displayed as integers. We would expect `world:mondo/0.0f0 → (3)` instead of `2:2/0.0f0 → (3)`. 
This is due to fact that, contrary to the formal definition, labels are not stored directly in the arcs but an index is used instead, which corresponds to the input/output symbol table:
```julia
julia> get_isym(A)
Dict{String,Int64} with 2 entries:
  "hello" => 1
  "world" => 2

julia> get_osym(A)
Dict{Symbol,Int64} with 2 entries:
  :mondo => 2
  :ciao  => 1
```

Another difference is in the definition of ``I``, ``F``, ``\lambda`` and ``\rho``.
These are also represented by dictionaries that can be accessed using the functions [`get_initial`](@ref) and [`get_final`](@ref).
```julia
julia> get_final(A)
Dict{Int64,TropicalWeight{Float32}} with 1 entry:
  3 => 0.0

```

## Epsilon label

```@docs
iseps
get_eps
```

By default `0` indicates the epsilon label which is not present in the symbol table.

Currently the following epsilon symbols are reserved for the following types:

| Type     |     Label |
|:--------:|:---------:|
| `Char`   | `'ϵ'`     |
| `String` | `"<eps>"` |
| `Int`    | `0`       |

We can define a particular type by extending the functions [`iseps`](@ref) and [`get_eps`](@ref).
For example if we want to introduce an epsilon symbol for the type `Symbol`:
```
julia> FiniteStateTransducers.iseps(x::Symbol) = x == :eps;

julia> FiniteStateTransducers.get_eps(x::Type{Symbol}) = :eps;

julia> add_arc!(A,3=>3,"world"=>:eps)
WFST #states: 3, #arcs: 5, #isym: 2, #osym: 2
|1/0.0f0|
hello:ciao/0.0f0 → (2)
world:mondo/0.0f0 → (3)
(2)
world:mondo/0.0f0 → (3)
((3/0.0f0))
world:ϵ/0.0f0 → (3)

julia> A[3]
1-element Array{Arc{TropicalWeight{Float32},Int64},1}:
 2:0/0.0f0 → (3)
```

## Properties

```@docs
length
size
isinitial
isfinal
typeofweight
has_eps
count_eps
is_acceptor
is_acyclic
is_deterministic
```

## Other constructors

```@docs
linearfst
matrix2wfst
```
