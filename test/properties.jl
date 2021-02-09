# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# get_ialphabet, get_oalphabet
ilabs = randn(10)
olabs = [randstring(1) for i =1:10]
isym = Dict( s=>i for (i,s) in enumerate(ilabs))
osym = Dict( s=>i for (i,s) in enumerate(olabs))
W = TropicalWeight{Float32}
fst = WFST(isym,osym)
@test typeofweight(fst) == W
add_arc!(fst, 1, 1, ilabs[1] , olabs[1] , rand()) 
add_arc!(fst, 1, 2, ilabs[2] , olabs[2] , rand()) 
add_arc!(fst, 2, 3, ilabs[3] , olabs[3] , rand()) 
add_arc!(fst, 2, 2, ilabs[4] , olabs[4] , rand()) 
add_arc!(fst, 3, 3, ilabs[5] , olabs[5] , rand()) 
add_arc!(fst, 3, 4, ilabs[6] , olabs[6] , rand()) 
add_arc!(fst, 4, 4, ilabs[7] , olabs[7] , rand()) 
add_arc!(fst, 4, 5, ilabs[8] , olabs[8] , rand()) 
add_arc!(fst, 5, 5, ilabs[9] , olabs[9] , rand()) 
add_arc!(fst, 5, 6, ilabs[10], olabs[10], rand()) 
add_arc!(fst, 6, 6, ilabs[10], olabs[10], rand()) 
initial!(fst,1)
final!(fst,6)
@test length(fst.isym) == 10
@test length(fst.osym) == 10
##println(fst)
A = get_ialphabet(fst)
B = get_oalphabet(fst)
@test eltype(A) <: AbstractFloat
@test eltype(B) <: String 

@test all(i in A for i in ilabs)
@test all(o in B for o in olabs)

## count_eps/has_eps/is_acceptor
isym = Dict(i=>i for i =1:5)
fst = WFST(isym)
ϵ = get_eps(Int)
add_arc!(fst, 1, 2, 5, 1, 0.5)
add_arc!(fst, 1, 3, 1, 1, rand()) 
add_arc!(fst, 2, 4, 1, ϵ, rand()) 
add_arc!(fst, 2, 3, 1, ϵ, rand()) 
add_arc!(fst, 2, 3, 2, 2, rand()) 
add_arc!(fst, 3, 4, 3, 3, rand()) 
add_arc!(fst, 3, 3, 4, 4, rand()) 

@test count_eps(get_ilabel,fst) == 0
@test count_eps(get_olabel,fst) == 2
@test has_eps(fst) == true
@test has_eps(get_ilabel,fst) == false
@test has_eps(get_olabel,fst) == true
@test is_acceptor(fst) == false
@test size(fst) == (4,7)

fst = WFST(isym)
add_arc!(fst, 1, 2, 1, 1, 0.5)
add_arc!(fst, 2, 3, 2, 2, 0.5)
@test is_acceptor(fst) == true

# is_deterministic
#ex form http://openfst.org/twiki/bin/view/FST/DeterminizeDoc
sym=Dict("$(Char(i))"=>i for i=97:122)
A = WFST(sym)
add_arc!(A,1,2,"a","p",1)
add_arc!(A,1,3,"a","q",2)
add_arc!(A,2,4,"c","r",4)
add_arc!(A,2,4,"c","r",5)
add_arc!(A,3,4,"d","s",6)
initial!(A,1)
final!(A,4)
#println(A)
@test is_deterministic(A) == false

B = WFST(sym)
add_arc!(B,1,2,"a","<eps>",1)
add_arc!(B,2,3,"c","p",4)
add_arc!(B,3,5,"<eps>","r",0)
add_arc!(B,2,4,"d","q",7)
add_arc!(B,4,5,"<eps>","s",0)
initial!(B,1)
final!(B,5)
#println(B)
@test is_deterministic(B) == true

# is_acyclic
A = WFST(sym)
add_arc!(A,1,2,"a","<eps>",1)
add_arc!(A,2,3,"c","p",4)
add_arc!(A,3,5,"<eps>","r",0)
add_arc!(A,2,4,"d","q",7)
add_arc!(A,4,5,"<eps>","s",0)
initial!(A,1)
final!(A,5)
#println(A)
@test is_acyclic(A)
add_arc!(A,5,1,"a","s",0)
@test !is_acyclic(A)
