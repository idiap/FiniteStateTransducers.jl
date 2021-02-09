# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# DFS iterator test
fst = WFST(Dict(1=>1))
add_arc!(fst, 1, 2, 1, 1, 1.0)
add_arc!(fst, 1, 5, 1, 1, 1.0)
add_arc!(fst, 1, 3, 1, 1, 1.0)
add_arc!(fst, 2, 6, 1, 1, 1.0)
add_arc!(fst, 2, 4, 1, 1, 1.0)
add_arc!(fst, 5, 4, 1, 1, 1.0)
add_arc!(fst, 3, 4, 1, 1, 1.0)
add_arc!(fst, 3, 7, 1, 1, 1.0)
initial!(fst,1)
println(fst)

println("DFS un-folded")
println("Starting from state 1")
dfs = FiniteStateTransducers.DFS(fst,1)
dfs_it = Int[]
completed_seq = Int[]
for (p,s,n,d,e,a) in dfs
  println("$p,$s,$n")
  if d == true
    println("visiting first time $n (Gray)")
    push!(dfs_it,n)
  else
    if e
      println("completed state $s (Black)")
      push!(completed_seq,s)
    else
      println("node $n already visited")
    end
  end
end
@test completed_seq == [6,4,2,5,7,3,1]
@test dfs_it == [2,6,4,5,3,7]

L = Int
fst = WFST(Dict(1=>1))
add_arc!(fst, 1, 2, 1, 1, 1.0)
add_arc!(fst, 2, 3, 1, 1, 1.0)
add_arc!(fst, 3, 1, 1, 1, 1.0)
add_arc!(fst, 3, 4, 1, 1, 1.0)
add_arc!(fst, 4, 5, 1, 1, 1.0)
add_arc!(fst, 5, 6, 1, 1, 1.0)
add_arc!(fst, 6, 7, 1, 1, 1.0)
add_arc!(fst, 7, 8, 1, 1, 1.0)
add_arc!(fst, 8, 5, 1, 1, 1.0)
add_arc!(fst, 2, 9, 1, 1, 1.0)
initial!(fst,1)
final!(fst,8)
println(fst)

println(fst)
scc, c, v = get_scc(fst)
@test scc == [[1, 2, 3], [9], [4], [5, 6, 7, 8]]

# is_visited test
L = Int
ϵ = get_eps(L)
fst = WFST(Dict(i=>i for i=1:4))
add_arc!(fst, 1 => 2, 1=>1,rand() )
add_arc!(fst, 1 => 3, 1=>1, rand()) 
add_arc!(fst, 2 => 4, 1=>ϵ, rand()) 
add_arc!(fst, 2 => 3, ϵ=>ϵ, rand()) 
add_arc!(fst, 2 => 3, 2=>2, rand()) 
add_arc!(fst, 3 => 4, 3=>3, rand()) 
add_arc!(fst, 3 => 3, 4=>4, rand()) 
#print(fst)
@test is_acceptor(fst) == false
## test rm_state!
@test count_eps(get_ilabel,fst) == 1
@test count_eps(get_olabel,fst) == 2
rm_state!(fst,2)
#print(fst)
@test is_acceptor(fst) == true
@test count_eps(get_ilabel,fst) == 0
@test count_eps(get_olabel,fst) == 0
@test size(fst) == (3,3)

# test DFS against recursive
I = O = Int32
fst = WFST(Dict(i=>i for i =1:5),Dict(100*i=>i for i =1:5))
w = randn(5)
add_arc!(fst, 1, 1, 1, 100*1, w[1])
add_arc!(fst, 1, 2, 1, 100*1, w[1])
add_arc!(fst, 1, 3, 2, 100*2, w[2])
add_arc!(fst, 1, 4, 3, 100*3, w[3])
add_arc!(fst, 2, 4, 4, 100*4, w[4])
add_arc!(fst, 3, 4, 5, 100*5, w[5])
initial!(fst, 1)
final!(fst, 4)
# fst have all nodes connected
v = FiniteStateTransducers.recursive_dfs(fst)
@test all(v)
fst2 = deepcopy(fst)
add_arc!(fst2, 8, 10, 5, 100*5, w[5])
add_arc!(fst2, 8, 9, 5, 100*5, w[5])
add_arc!(fst2, 8, 8, 5, 100*5, w[5])
# fst2 5 < state <= 10 are not connected with previous ones
add_arc!(fst2, 3, 11, 5, 100*5, w[5])
add_arc!(fst2, 11, 12, 5, 100*5, w[5])
add_arc!(fst2, 12, 12, 5, 100*5, w[5])
final!(fst2,12,w[1])
# fst2 state >= 11 are connected with first nodes
v = FiniteStateTransducers.recursive_dfs(fst2)
@test all(v[1:4])
@test all(.!v[5:10])
@test all(v[11:end])

# testing lazy version
v = is_visited(fst)
@test all(v)
v = is_visited(fst2)
@test all(v[1:4])
@test all(.!v[5:10])
@test all(v[11:end])
v = is_visited(fst2,8)
@test all(v[8:10])
@test all(.!v[1:7])
@test all(.!v[11:end])

# connect tests
#println(fst2)
## testing connect
fst3 = connect(fst2)
@test all(is_visited(fst3))
@test size(fst3) == (6,9)
@test isfinal(fst3,6)
@test isfinal(fst3,4)
@test isinitial(fst3,1)
@test get(get_weight(fst3,6)) ≈ w[1]
