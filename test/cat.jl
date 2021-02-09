# example from http://openfst.org/twiki/bin/view/FST/ConcatDoc
sym=Dict("$(Char(i))"=>i for i=97:122)

A = WFST(sym)
add_arc!(A,1=>2,"<eps>"=>"<eps>")
add_arc!(A,2=>2,"a"=>"p", 2)
add_arc!(A,2=>3,"b"=>"q", 3)
add_arc!(A,3=>3,"c"=>"r", 4)
add_arc!(A,3=>2,"<eps>"=>"<eps>", 5)
initial!(A,1)
final!(A,1)
final!(A,3,5)
#println(A)

B = WFST(sym)
add_arc!(B,1=>1,"a"=>"p",2)
add_arc!(B,1=>2,"b"=>"q",3)
add_arc!(B,2=>2,"c"=>"r",4)
initial!(B,1)
final!(B,2,5)
#println(A)

W,D = typeofweight(A),Int

C = A*B
#println(C)
@test size(C) == (5,10)
@test get_initial(C; single=false) == Dict(1=>one(W))
@test get_final(C; single=false) == Dict(5=>W(5))
@test C[1][1] == Arc{W,D}(0,0,one(W),2)
@test C[1][2] == Arc{W,D}(0,0,one(W),4)
@test C[2][1] == Arc{W,D}(sym["a"],sym["p"],W(2),2)
@test C[2][2] == Arc{W,D}(sym["b"],sym["q"],W(3),3)
@test C[3][1] == Arc{W,D}(sym["c"],sym["r"],W(4),3)
@test C[3][2] == Arc{W,D}(0,0,W(5),2)
@test C[3][3] == Arc{W,D}(0,0,W(5),4)
@test C[4][1] == Arc{W,D}(sym["a"],sym["p"],W(2),4)
@test C[4][2] == Arc{W,D}(sym["b"],sym["q"],W(3),5)
@test C[5][1] == Arc{W,D}(sym["c"],sym["r"],W(4),5)

B = WFST(sym,["z"]); initial!(B,1); final!(B,2)
@test_throws ErrorException A*B
B = WFST(["z"],sym); initial!(B,1); final!(B,2)
@test_throws ErrorException A*B
B = WFST(sym; W = ProbabilityWeight{Float32}); initial!(B,1); final!(B,2)
@test_throws ErrorException A*B
###
### with deterministic acyclic WFSTs
W = ProbabilityWeight{Float64}
isym=Dict("$(Char(i))"=>i for i=97:122)
osym=Dict(Char(i)=>i for i=97:122)
A = WFST(isym,osym; W = W)
add_arc!(A,1=>2,"a"=>'a',1)
add_arc!(A,2=>4,"b"=>'b',2)
add_arc!(A,2=>3,"c"=>'c',3)
add_arc!(A,3=>4,"d"=>'d',4)
add_arc!(A,1=>4,"e"=>'e',5)
initial!(A,1)
final!(A,3,6)
final!(A,4,7)
println(A)

B = WFST(isym,osym; W = W)
add_arc!(B,1=>2,"x"=>'x',8)
add_arc!(B,1=>3,"y"=>'y',9)
initial!(B,1)
final!(B,2,10)
final!(B,3,11)
println(B)

pas = collectpaths(A)
pbs = collectpaths(B)
C = A*B
pcs = collectpaths(C)
@test all([pa*pb in pcs for pa in pas, pb in pbs])

C = B*A
pcs = collectpaths(C)
@test all([pb*pa in pcs for pa in pas, pb in pbs])

C = A*A
pcs = collectpaths(C)
@test all([pa*pa in pcs for pa in pas, pb in pbs])

C = B*B
pcs = collectpaths(C)
@test all([pb*pb in pcs for pa in pas, pb in pbs])
