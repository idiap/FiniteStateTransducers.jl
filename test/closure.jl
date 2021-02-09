# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

fst = WFST(["a","b","c"],["p","q","r"])
add_arc!(fst,1,1,"a","p",2)
add_arc!(fst,1,2,"b","q",3)
add_arc!(fst,2,2,"c","r",4)
initial!(fst,1)
final!(fst,2,5)

fst_plus = closure(fst; star=false)
println(fst_plus)

fst_star = closure(fst; star=true)
println(fst_star)
@test isinitial(fst_star,3)
@test isfinal(fst_star,3)
@test isfinal(fst_star,2)

W = typeofweight(fst)
ilabels=["a","b","c"]
o1,w1 = fst(ilabels)
@test o1 == ["p","q","r"]
@test w1 == W(2)*W(3)*W(4)*W(5) 
o2,w2 = fst_star([ilabels;ilabels])
@test o2 == [o1;o1]
@test w2 == w1*w1
o3,w3 = fst_star([ilabels;ilabels])
@test o3 == o3
@test w2 == w3
o,w = fst([ilabels;ilabels])
@test w == zero(W)

# fst star accepts empty string and returns the same with weight one
o,w = fst_star(String[])
@test o == String[]
@test w == one(W)

# fst plus does not accept empty string
o,w = fst_plus(String[])
@test w == zero(W)
