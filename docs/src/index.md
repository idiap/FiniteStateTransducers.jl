# FiniteStateTransducers.jl

Play with Weighted Finite State Transducers (WFSTs) using the Julia language.

WFSTs provide a powerful framework that assigns a weight (e.g. probability) to conversions of symbol sequences. 
WFSTs are used in many applications such as speech recognition, natural language processing and machine learning.

This package takes a lot of inspiration from [OpenFST](http://openfst.org/twiki/bin/view/FST/DeterminizeDoc).

FiniteStateTransducers is still in an early development stage, see the documentation for currently available features and issues for the missing ones.

## Installation

To install the package, simply issue the following command in the Julia REPL:

```julia
] add FiniteStateTransducers
```

## Acknowledgements

This work was developed under 
the supsrvision of Prof. Dr. Hervé Bourlard
and supported by the Swiss National Science Foundation
under the project 
"Sparse and hierarchical Structures for Speech Modeling" (SHISSM)
(no. 200021.175589).
