# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

### fsa2transition
# transition matrix 3 state HMM with self loop in the middle 
H = WFST(["a1","a2","a3"],["a"]);

add_arc!(H,1,2,"a1","a");
add_arc!(H,2,3,"a2","<eps>");
add_arc!(H,2,2,"a2","<eps>");
add_arc!(H,3,4,"a3","<eps>");
add_arc!(H,3,2,"a3","a");
initial!(H,1);
final!(H,4)
#println(H)

Nt = 10;
time2tr = wfst2tr(H,Nt)
#println(time2tr)

@test length(time2tr) == Nt-1
@test all([ all(keys(tr) .<= length(get_isym(H)) ) for tr in time2tr])
