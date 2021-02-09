# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

fst = WFST(["a","b","c","d","f"])
add_arc!(fst,1,2,"a","a",3)
add_arc!(fst,2,2,"b","b",2)
add_arc!(fst,2,4,"c","c",4)
add_arc!(fst,1,3,"d","d",5)
add_arc!(fst,3,4,"f","f",4)
initial!(fst,1)
final!(fst,4,3)
#println(fst)

d = shortest_distance(fst)
@test all(get.(d) .== Float32[0.0;3.0;5.0;7.0])

d = shortest_distance(fst;reversed=true)
@test all(get.(d) .== Float32[10.0;7.0;7.0;3.0])
