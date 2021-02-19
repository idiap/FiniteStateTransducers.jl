# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export txt2fst
"""
`txt2fst(path_or_text,isym[,osym];W=TropicalWeight{Float32})`

Loads a WFST from a text file using [OpenFST format](http://openfst.org/twiki/bin/view/FST/FstQuickTour).

`isym` and `osym` can be either dictionaries or paths to the input/output symbol list.

If `path_or_text` is not a path, the input string is parsed directly.
```julia
julia> txt2fst("0 1 a a 3.0
       1 2 b <eps> 77.0
       2 3 c <eps> 33.0
       3 4 d d 44.0
       4 90.0
       ",Dict("a"=>1,"b"=>2,"c"=>3,"d"=>4))
WFST #states: 5, #arcs: 4, #isym: 4, #osym: 4
|1/0.0f0|
a:a/3.0f0 → (2)
(2)
b:ϵ/77.0f0 → (3)
(3)
c:ϵ/33.0f0 → (4)
(4)
d:d/44.0f0 → (5)
((5/90.0f0))

```
"""
function txt2fst(path::AbstractString,
                 isym::AbstractDict,
                 osym::AbstractDict=isym;W=TropicalWeight{Float32})
  fst = WFST(isym,osym; W=W)
  fst_txt = isfile(path) ? read(path, String) : path
  for x in split(fst_txt,"\n"; keepempty=false)
    arc = split(x)
    s = parse(Int,arc[1])+1
    if length(arc) <= 2 # final node with no weight
      N =s-length(fst)
      if N > 0
        add_states!(fst,N)
      end
      w = length(arc) == 2 ? parse(W,arc[2]) : one(W)
      final!(fst,s,w)
    elseif length(arc) >= 4
      n = parse(Int,arc[2])+1
      i = typeof(arc[3]) <: AbstractString ? String(arc[3]) : parse(I,arc[3])
      o = typeof(arc[4]) <: AbstractString ? String(arc[4]) : parse(O,arc[4])
      w = length(arc) == 5 ? parse(W,arc[5]) : one(W)
      add_arc!(fst,s,n,i,o,w.x)
    end
  end
  initial!(fst,1)
  return fst
end

txt2fst(path::AbstractString,path_sym::AbstractString; kwargs...) =
txt2fst(path,txt2sym(path_sym); kwargs...)

txt2fst(path::AbstractString,path_isym::AbstractString,path_osym::AbstractString; kwargs...) =
txt2fst(path,txt2sym(path_isym),txt2sym(path_osym); kwargs...)

export txt2sym
"""
`txt2sym(path)`

Loads a symbol list from a text file into a `Dict` using [OpenFST convention](http://openfst.org/twiki/bin/view/FST/FstQuickTour).
"""
function txt2sym(path)
  sym_txt = read(path,String)
  sym = Dict{String,Int}()
  for x in split(sym_txt,"\n"; keepempty=false)
    z = strip.(split(x))
    if length(z) > 2
      throw(ErrorException("Invalid symbol table `$x` in `$path`"))
    end
    if z[1] != "<eps>"
      sym[String(z[1])] = parse(Int,z[2])
    end
  end
  return sym
end

export fst2dot
"""
`fst2dot(fst)`

Converts the `fst` to a string in the [dot format](https://graphviz.org/doc/info/lang.html).

Useful to visualise large FSTs using Graphviz.
"""
function fst2dot(fst::WFST)
  x = "digraph FST {\nrankdir=LR;\nbgcolor=\"transparent\"\n;\ncenter=1;\n"
  int2isym = get_iisym(fst)
  int2osym = get_iosym(fst)
  for (i,s) in enumerate(fst)
    if isfinal(fst,i)
      w = get_final_weight(fst,i) 
      x *= "$i [label = \"$(i)/$(w)\", shape = circle, style = bold, fontsize = 14]\n"
    elseif isinitial(fst,i)
      w = get_initial_weight(fst,i) 
      x *= "$i [label = \"$(i)/$(w)\", shape = doublecircle, style = solid, fontsize = 14]\n"
    else
      x *= "$i [label = \"$(i)\", shape = circle, style = solid, fontsize = 14]\n"
    end
    for arc in s
      ilabel = idx2string(get_ilabel(arc),int2isym)
      olabel = idx2string(get_olabel(arc),int2osym)
      n = get_nextstate(arc)
      w = get_weight(arc)
      x*="\t$(i) -> $(n) [label = \"$(ilabel):$(olabel)/$(w)\", fontsize = 14];\n"
    end
  end
  x *="}"
  return x
end

export fst2pdf
"""
`fst2pdf(fst,pdffile)`

Prints the `fst` to a pdf file using [Graphviz](https://graphviz.org/).

Requires Graphviz to be intalled.
"""
function fst2pdf(fst,file)
  tmp = mktempdir()
  dot = fst2dot(fst)
  dotfile = joinpath(tmp,"fst.dot")
  write(dotfile,dot)
  write(file, read(`dot -Tpdf $dotfile`))
end
