# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

W = TropicalWeight{Float64}
sym=Dict("$(Char(i))"=>i for i=97:122)
fst = WFST(sym; W = W)
add_arc!(fst,1,3,"<eps>","<eps>",one(W))
add_arc!(fst,3,6,"f","f",one(W))
add_arc!(fst,6,4,"d","d",one(W))
add_arc!(fst,1,4,"a","a",one(W))
add_arc!(fst,4,5,"c","c",one(W))
add_arc!(fst,5,7,"b","b",one(W))
add_arc!(fst,7,2,"a","a",one(W))
add_arc!(fst,5,2,"b","b",one(W))
initial!(fst,1)
final!(fst,2)
println(fst)

perm = topsortperm(fst)
@test perm == [1,3,6,4,5,7,2]

sorted_fst = topsort(fst)
@test size(sorted_fst) == size(fst)
@test topsortperm(sorted_fst) == [1,2,3,4,5,6,7]
@test isfinal(sorted_fst,7)

# fails if fst has cycles
add_arc!(fst,2,1,"z","z",one(W))
@test_throws ErrorException topsort(fst)
