# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

isym=txt2sym("openfst/sym.txt")

S = String
fst = txt2fst("openfst/A.fst", isym)
#println(fst)
@test size(fst) == (5,4)
fst = txt2fst("openfst/B.fst", "openfst/sym.txt")
#println(fst)
@test size(fst) == (4,3)
fst = txt2fst("openfst/C_trivial.fst", "openfst/sym.txt")
#println(fst)
@test size(fst) == (8,11)
fst = txt2fst("openfst/L.fst", "openfst/chars.txt", "openfst/words.txt")
@test size(fst) == (14,18)
#println(fst)
## TODO add many more tests

dot = fst2dot(fst)
# fst2pdf needs dot to be installed
if success(`which dot`)
  fst2pdf(fst,"fst.pdf")
end
