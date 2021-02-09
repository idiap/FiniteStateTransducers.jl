fstcompile --isymbols=sym.txt --osymbols=sym.txt \
  A.fst A.bfst
fstcompile --isymbols=sym.txt --osymbols=sym.txt \
  B.fst B.bfst

for type in trivial sequence match;do
fstcompose --compose_filter=$type \
  A.bfst B.bfst C.bfst
fstprint --isymbols=sym.txt --osymbols=sym.txt \
  C.bfst C_${type}.fst
done

fstcompile --isymbols=chars.txt --osymbols=words.txt \
  L.fst L.bfst

fstcompile --isymbols=chars.txt --osymbols=chars.txt \
  determinizeme.fst determinizeme.bfst
fstdeterminize determinizeme.bfst determinized.bfst
fstprint --isymbols=chars.txt --osymbols=chars.txt \
  determinized.bfst determinized.fst

#fstdraw --portrait=true --isymbols=chars.txt \
#  --osymbols=words.txt L.bfst | dot -Tpdf > L.pdf

fstcompile --isymbols=words.txt --osymbols=words.txt \
  T.fst T.bfst
fstcompose \
  L.bfst T.bfst LT.bfst
fstprint --isymbols=chars.txt --osymbols=words.txt \
  LT.bfst LT.fst
fstdraw --portrait=true --isymbols=chars.txt \
  --osymbols=words.txt LT.bfst | dot -Tpdf > LT.pdf

rm *.bfst
