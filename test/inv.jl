# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# inverse
ilab = 1:10
olab = [randstring(1) for i =1:10]
fst = WFST(ilab,olab)
add_arc!(fst, 1, 1, ilab[1] , olab[1] , rand()) 
add_arc!(fst, 1, 2, ilab[2] , olab[2] , rand()) 
add_arc!(fst, 2, 3, ilab[3] , olab[3] , rand()) 
add_arc!(fst, 2, 2, ilab[4] , olab[4] , rand()) 
add_arc!(fst, 3, 3, ilab[5] , olab[5] , rand()) 
add_arc!(fst, 3, 4, ilab[6] , olab[6] , rand()) 
add_arc!(fst, 4, 4, ilab[7] , olab[7] , rand()) 
add_arc!(fst, 4, 5, ilab[8] , olab[8] , rand()) 
add_arc!(fst, 5, 5, ilab[9] , olab[9] , rand()) 
add_arc!(fst, 5, 6, ilab[10], olab[10], rand()) 
initial!(fst,1)
final!(fst,6,rand())
ifst = inv(fst)
@test all([a in ilab for a in get_oalphabet(ifst)])
@test all([a in olab for a in get_ialphabet(ifst)])
@test isfinal(ifst,6)
@test isinitial(ifst,1)
@test get_weight(fst,6) == get_weight(ifst,6)
