# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# compose 
# using ex from Mohri et al. Speech recognition with FiniteStateTransducers 
L = String
W = TropicalWeight{Float32}
A = WFST(["a","b","c"]; W = W)
add_arc!(A, 1, 2, "a", "b", 0.1) 
add_arc!(A, 2, 2, "c", "a", 0.3) 
add_arc!(A, 2, 4, "a", "a", 0.4) 
add_arc!(A, 1, 3, "b", "a", 0.2) 
add_arc!(A, 3, 4, "b", "b", 0.2) 
final!(A, 4, 0.6)
initial!(A, 1)
#println(A)
size_A = size(A)
B = WFST(get_isym(A); W = W)
add_arc!(B, 1, 2, "b", "c", 0.3) 
add_arc!(B, 2, 3, "a", "b", 0.4) 
add_arc!(B, 3, 3, "a", "b", 0.6) 
final!(B, 3, 0.7)
initial!(B, 1)
size_B = size(B)
#println(B)

C = ∘(A,B; filter=Trivial)
#println(C)
@test size(A) == size_A
@test size(B) == size_B
@test isinitial(C,1)
@test isfinal(C,4)
@test get_weight(C,4) ≈ W(1.3)
@test get_weight(C[1][1]) ≈ W(0.4)
@test get_weight(C[2][1]) ≈ W(0.7)
@test get_weight(C[2][2]) ≈ W(0.8)
@test get_weight(C[3][1]) ≈ W(0.9)
@test get_weight(C[3][2]) ≈ W(1.0)
@test size(C) == (4,5)

# using ex from http://openfst.org/twiki/bin/view/FST/ComposeDoc 
L = String
W = TropicalWeight{Float64}
A = WFST(["a","c"],["q","r","s"]; W=W)
add_arc!(A, 1, 2, "a", "q", 1.0) 
add_arc!(A, 2, 2, "c", "s", 1.0) 
add_arc!(A, 1, 3, "a", "r", 2.5) 
initial!(A,1)
final!(A,2,0)
final!(A,3,2.5)
#print(A)

W = TropicalWeight{Float64}
B = WFST(get_osym(A),["f","h","g","j"]; W=W)
add_arc!(B, 1, 2, "q", "f", 1.0) 
add_arc!(B, 1, 3, "r", "h", 3.0) 
add_arc!(B, 2, 3, "s", "g", 2.5) 
add_arc!(B, 3, 3, "s", "j", 1.5) 
initial!(B,1)
final!(B,3,2)
#print(B)

C = ∘(A,B,filter=Trivial)
#println(C)

@test isinitial(C,1)
@test isfinal(C,3)
@test isfinal(C,4)
@test get_weight(C,3) ≈ W(4.5)
@test get_weight(C,4) ≈ W(2.0)
@test get_weight(C[1][1]) ≈ W(2.0)
@test get_ilabel(C,1,1) == "a"
@test get_olabel(C,1,1) == "f"
@test get_nextstate(C[1][1]) == 2
@test get_weight(C[1][2]) ≈ W(5.5)
@test get_ilabel(C,1,2) == "a"
@test get_olabel(C,1,2) == "h"
@test get_nextstate(C[1][2]) == 3
@test get_weight(C[2][1]) ≈ W(3.5)
@test get_ilabel(C,2,1) == "c"
@test get_olabel(C,2,1) == "g"
@test get_nextstate(C[2][1]) == 4
@test get_weight(C[4][1]) ≈ W(2.5)
@test get_ilabel(C,4,1) == "c"
@test get_olabel(C,4,1) == "j"
@test get_nextstate(C[4][1]) == 4
@test size(C) == (4,4)

# using ex fig.8 (with different weights) from Mohri et al. Speech recognition with FiniteStateTransducers 
# with epsilon symbols
A = txt2fst("openfst/A.fst", "openfst/sym.txt")
B = txt2fst("openfst/B.fst", "openfst/sym.txt")
# TODO add tests
# for the moment we test equivalence of fst with sorted weights
C = ∘(A,B;filter=Trivial)
C_openfst = txt2fst("openfst/C_trivial.fst", "openfst/sym.txt")
@test size(C) == size(C_openfst) 
w = sort([get_weight(a).x for a in get_arcs(C)])
w_openfst = sort([get(get_weight(a)) for a in get_arcs(C_openfst)])
@test all(w .== w_openfst)
@test all(sort([values(C.finals)...]) .== sort([values(C_openfst.finals)...] ))
#println(C)
#println(C_openfst)

C = ∘(A,B;filter=EpsMatch)
C_openfst = txt2fst("openfst/C_match.fst", "openfst/sym.txt")
@test size(C) == size(C_openfst)
w = sort([get_weight(a).x for a in get_arcs(C)])
w_openfst = sort([get(get_weight(a)) for a in get_arcs(C_openfst)])
@test all(w .== w_openfst)
@test all(sort([values(C.finals)...]) .== sort([values(C_openfst.finals)...] ))
#println(C)
#println(C_openfst)

C = ∘(A,B;filter=EpsSeq)
C_openfst = txt2fst("openfst/C_sequence.fst", "openfst/sym.txt")
@test size(C) == size(C_openfst) 
w = sort([get_weight(a).x for a in get_arcs(C)])
w_openfst = sort([get(get_weight(a)) for a in get_arcs(C_openfst)])
@test all(w .== w_openfst)
@test all(sort([values(C.finals)...]) .== sort([values(C_openfst.finals)...] ))
#println(C)
#println(C_openfst)

## 
L = txt2fst("openfst/L.fst", "openfst/chars.txt", "openfst/words.txt")
#println(L)
T = txt2fst("openfst/T.fst", "openfst/words.txt", "openfst/words.txt")
#println(T)
LT = ∘(L,T;filter=EpsSeq)
#println(LT)
@test size(LT) ==(11,10)
@test_throws ErrorException T∘L # since A.osym != A.isym
