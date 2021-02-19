# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# weighted arc definition
W = ProbabilityWeight{Float32}
a1 = FiniteStateTransducers.Arc(1,1,W(0.5),2)
a2 = FiniteStateTransducers.Arc(1,1,W(0.5),2)
a3 = FiniteStateTransducers.Arc(1,1,W(0.8),2)
@test a1 == a2
@test (a1 == a3) == false
@test ==(a1,a3;check_weight=false) == true

# WFST constructor
isym = Dict(i=>i for i =1:5)
fst = WFST(isym; W = W)
add_states!(fst,4) # create 4 states
@test length(fst) == 4
initial!(fst,1)
@test 1 in get_initial(fst)
@test isinitial(fst,1) == true
final!(fst,4,0.5)
final!(fst,3)
@test 4 in keys(get_final(fst))
@test isfinal(fst,3) == true
initial!(fst,1,W(0.2))
### add arcs
ϵ = get_eps(Int)
add_arc!(fst, 1=>2, 5=>1)
add_arc!(fst, 1, 3, 1, 1, rand()) 
add_arc!(fst, 2, 4, 1, ϵ, rand()) 
add_arc!(fst, 2, 3, 1, ϵ, rand()) 
add_arc!(fst, 2, 3, 2, 2, rand()) 
add_arc!(fst, 3, 4, 3, 3, rand()) 
add_arc!(fst, 3, 3, 4, 4, rand()) 
@test_throws ErrorException add_arc!(fst, 3, 3, 6, 6, rand()) 
println(fst)
initial!(fst,2)
rm_initial!(fst,1)
@test get_initial(fst;single=true) == 2
rm_initial!(fst,2)
@test_throws ErrorException get_initial(fst)
rm_final!(fst,4)
println(fst)
rm_final!(fst,3)
@test_throws ErrorException get_final(fst)

## testing linear wfst
fst = linearfst([1,1,3,4],[1,2,3,4],rand(4),isym)
@test size(fst) == (5,4)
@test isinitial(fst,1)
@test isfinal(fst,5)

fst = linearfst([1,1,3,4],[:a,:b,:c,:d],rand(4))
@test length(get_isym(fst)) == 3
@test eltype(keys(get_isym(fst))) == Int
@test length(get_osym(fst)) == 4
@test eltype(keys(get_osym(fst))) == Symbol

### matrix2fsa
Ns,Nt=3,10
sym=Dict("a"=>1,"b"=>2,"c"=>3)
X = rand(Ns,Nt)
fst = matrix2wfst(sym,X)
#println(fst)
@test size(fst) == (Nt+1,Ns*Nt)
@test isinitial(fst,1)
@test isfinal(fst,Nt+1)

fst = matrix2wfst([:a,:b,:c],X)
@test eltype(keys(get_isym(fst))) == Symbol
@test length(get_isym(fst)) == 3
@test get_isym(fst) == get_osym(fst)

X[2,2] = Inf # this is a tropical zero so no arc should be added
fst = matrix2wfst(sym,X; W = TropicalWeight{Float32})
@test size(fst) == (Nt+1,Ns*Nt-1)
@test isinitial(fst,1)
@test isfinal(fst,Nt+1)

# transduce symbol seq
isym=Dict(Char(i)=>i for i=97:122)
osym=Dict(Char(i)=>i for i=97:122)
W = ProbabilityWeight{Float64} 
A = WFST(isym,osym; W=W); 
add_arc!(A,1=>2,'h'=>'w',1)
add_arc!(A,2=>3,'e'=>'o',1)
add_arc!(A,3=>4,'l'=>'r',1)
add_arc!(A,4=>5,'l'=>'l',1)
add_arc!(A,5=>6,'o'=>'d',1)
add_arc!(A,5=>6,'ϵ'=>'d',0.001)
add_arc!(A,6=>6,'o'=>'ϵ',0.5)
initial!(A,1)
final!(A,6)
#println(A)
out,w = A(['h', 'e', 'l', 'l', 'o'])
@test out == ['w', 'o', 'r', 'l', 'd']
@test w == one(W)
out,w = A(['e', 'l'])
@test isempty(out)
@test w == zero(W)
out,w = A(['h'])
@test out == ['w']
@test w == zero(W)
out,w = A(['h'])
@test out == ['w']
@test w == zero(W)
out,w = A(['h', 'e', 'l', 'l', 'o', 'o', 'o', 'o'])
@test out == ['w', 'o', 'r', 'l', 'd']
@test w == W(0.5^3) # 3 times in self loop
out,w = A(['h', 'e', 'l', 'l', 'ϵ', 'o', 'o', 'o'])
@test out == ['w', 'o', 'r', 'l', 'd']
@test w == W(0.5^2) # 2 times in self loop
out,w = A(['h', 'e', 'l', 'l'])
@test out == ['w', 'o', 'r', 'l', 'd']
@test w == W(0.001)

B = WFST(isym,osym; W=W); 
add_arc!(B,1=>2,'h'=>'n',1)
add_arc!(B,2=>3,'e'=>'ϵ',1)
add_arc!(B,3=>4,'ϵ'=>'ϵ',1)
add_arc!(B,4=>5,'l'=>'ϵ',1)
add_arc!(B,5=>6,'l'=>'ϵ',1)
add_arc!(B,6=>7,'ϵ'=>'o',1)
add_arc!(B,7=>7,'l'=>'ϵ',0.5)
initial!(B,1)
final!(B,7)
out,w = B(['h', 'e', 'l', 'l'])
@test out == ['n', 'o']
@test w == one(W)
out,w = B(['h', 'e', 'l', 'l', 'l', 'l'])
@test out == ['n', 'o']
@test w == W(0.5^2)
