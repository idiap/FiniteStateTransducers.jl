# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# example from http://openfst.org/twiki/bin/view/FST/RmEpsilonDoc
W = TropicalWeight{Float64}
A = WFST(Dict("a"=>1,"p"=>2),W = W)
add_arc!(A,1,2,"<eps>","<eps>",1)
add_arc!(A,2,3,"a","<eps>",2)
add_arc!(A,2,3,"<eps>","p",3)
add_arc!(A,2,3,"<eps>","<eps>",4)
add_arc!(A,3,3,"<eps>","<eps>",5)
add_arc!(A,3,4,"<eps>","<eps>",6)
final!(A,4,7)
initial!(A,1)

# println(A)
B = rm_eps(A)
# println(B)
@test isinitial(B,1)
@test get_final_weight(B,1) == W(18)
@test get_initial_weight(B,1) == one(W)
@test isfinal(B,1)
@test isfinal(B,2)
@test get_final_weight(B,2) == W(13)
@test B[1][1] == FiniteStateTransducers.Arc{W,Int}(1,0,W(3),2)
@test B[1][2] == FiniteStateTransducers.Arc{W,Int}(0,2,W(4),2)
@test size(B) == (2,2)
