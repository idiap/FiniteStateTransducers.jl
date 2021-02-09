# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

sym=Dict("$(Char(i))"=>i for i=97:122)
A = WFST(sym)
W = typeofweight(A)
add_arc!(A,1,2,"a","a",1)
add_arc!(A,1,3,"a","a",2)
add_arc!(A,2,2,"b","b",3)
add_arc!(A,3,3,"b","b",3)
add_arc!(A,2,4,"c","c",5)
add_arc!(A,3,4,"d","d",6)
initial!(A,1)
final!(A,4)
println(A)
@test is_deterministic(A) == false
@test is_acceptor(A)
D = determinize_fsa(A)
#println(D)
@test is_deterministic(D)
@test size(D) == (3,4)
# TODO add more tests
