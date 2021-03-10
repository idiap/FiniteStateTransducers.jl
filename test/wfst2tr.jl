# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

### fsa2transition
# transition matrix 3 state HMM with self loop in the middle 
H = WFST(["a1","a2","a3"],["a"]);

add_arc!(H,1,2,"a1","a");
add_arc!(H,2,2,"a1","<eps>",-log(0.3));
add_arc!(H,2,3,"a2","<eps>",-log(0.7));
add_arc!(H,3,3,"a2","<eps>",-log(0.3));
add_arc!(H,3,4,"a3","<eps>",-log(0.7));
add_arc!(H,4,4,"a3","<eps>",-log(0.3));
add_arc!(H,4,2,"a1","a",-log(0.7));
initial!(H,1);
final!(H,4)
#println(H)

Nt = 10;
time2tr = wfst2tr(H,Nt)
#println(time2tr)

@test length(time2tr) == Nt-1
@test all([ all(keys(tr) .<= length(get_isym(H)) ) for tr in time2tr])

a,A = wfst2tr(H; convert_weight = w -> exp(-get(w)))
@test all(abs.(sum(A,dims=2) .- 1) .< 1e-6)
@test abs(sum(a) - 1) .< 1e-6
