# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

fst = WFST(["a","b","c","d","e","f"])
add_arc!(fst,1=>1,"a"=>"a",2)
add_arc!(fst,1=>2,"a"=>"a",1)
add_arc!(fst,2=>3,"b"=>"b",3)
add_arc!(fst,2=>3,"c"=>"c",4)
add_arc!(fst,3=>3,"d"=>"d",5)
add_arc!(fst,3=>4,"d"=>"d",6)
add_arc!(fst,4=>4,"f"=>"f",2)
initial!(fst,1)
final!(fst,2,3)
final!(fst,4,2)
#println(fst)
sym = get_isym(fst)
W = typeofweight(fst)
D = Int

rfst = reverse(fst)
@test rfst[1][1] == Arc{W,D}(0,0,W(3),3)
@test rfst[1][2] == Arc{W,D}(0,0,W(2),5)
@test rfst[2][1] == Arc{W,D}(sym["a"],sym["a"],W(2),2)
@test rfst[3][1] == Arc{W,D}(sym["a"],sym["a"],W(1),2)
@test rfst[4][1] == Arc{W,D}(sym["b"],sym["b"],W(3),3)
@test rfst[4][2] == Arc{W,D}(sym["c"],sym["c"],W(4),3)
@test rfst[4][3] == Arc{W,D}(sym["d"],sym["d"],W(5),4)
@test rfst[5][1] == Arc{W,D}(sym["d"],sym["d"],W(6),4)
@test rfst[5][2] == Arc{W,D}(sym["f"],sym["f"],W(2),5)
@test size(rfst) == (5,9)

fst = WFST([1,2],["a","b"];W = LeftStringWeight)
add_arc!(fst,1=>2,1=>"a","ciao")
add_arc!(fst,2=>3,2=>"b","bello")
initial!(fst,1)
final!(fst,3)
rfst = reverse(fst)
#println(rfst)

seq = [1,2]
out, w = fst(seq)
outr, wr = rfst(reverse(seq))
@test out == reverse(outr)
@test w == reverse(wr)
