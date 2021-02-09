# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# Path constructor
isym = ["a","b","c","d"];
osym = ["α","β","γ","δ"];
W = ProbabilityWeight{Float32};
p = Path(isym,osym,["a","b","c"] => ["α","β","γ"], one(W))
@test get_weight(p) == one(W)
FiniteStateTransducers.update_path!(p, 4, 4, 0.5)
@test get_weight(p) == W(0.5)
println(p)

p = Path(isym,["a","b","c"] => ["c","b","a"])
println(p)
@test typeofweight(p) == TropicalWeight{Float32} 
@test get_weight(p) == one(TropicalWeight{Float32})

isym = ["a","b","c","d","e"];
osym = ["α","β","γ","δ","ε"];
W = ProbabilityWeight{Float32}
fst = WFST(isym,osym; W=W)
w = randn(6)
add_arc!(fst, 1, 2, "a", "α", w[1])
add_arc!(fst, 1, 3, "b", "β", w[2])
add_arc!(fst, 1, 4, "c", "γ", w[3])
add_arc!(fst, 2, 4, "d", "δ", w[4])
add_arc!(fst, 3, 4, "e", "ε", w[5])
initial!(fst, 1)
wf = rand()
final!(fst, 4, wf)
paths = collectpaths(fst)
for p in get_paths(fst)
  @test p in paths
end
@test length(paths) == 3
@test all( sort(get.(get_weight.(paths))) .≈ sort([w[1]*w[4]*wf, w[2]*w[5]*wf, w[3]*wf]) )

@test get_isequence(paths[1]) == ["c"]
@test get_isequence(paths[2]) == ["a","d"]
@test get_isequence(paths[3]) == ["b","e"]

@test get_osequence(paths[1]) == ["γ"]
@test get_osequence(paths[2]) == ["α","δ"]
@test get_osequence(paths[3]) == ["β","ε"]

# empty fst
fst = WFST(Dict(1=>1); W = W)
@test_throws ErrorException collectpaths(fst)
@test_throws ErrorException get_paths(fst)

# with eps
I = O = Int32
isym = Dict(i=>i     for i=1:5)
osym = Dict(100*i=>i for i=1:5)
fst = WFST(isym,osym; W = ProbabilityWeight{Float32})
w = randn(6)
ϵ = get_eps(I)
add_arc!(fst, 1, 2, 1, 100*1, w[1])
add_arc!(fst, 1, 3, 2,     ϵ, w[2])
add_arc!(fst, 1, 4, ϵ,     ϵ, w[3])
add_arc!(fst, 2, 4, 4, 100*4, w[4])
add_arc!(fst, 3, 4, 5, 100*5, w[5])
initial!(fst, 1)
wf = rand()
final!(fst, 4, wf)
paths = collectpaths(fst)
for p in get_paths(fst)
  @test p in paths
end
@test all( sort(get.(get_weight.(paths))) .≈ sort([w[1]*w[4]*wf, w[2]*w[5]*wf, w[3]*wf]) )
