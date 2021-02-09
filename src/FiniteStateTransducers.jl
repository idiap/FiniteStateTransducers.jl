# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

module FiniteStateTransducers

using DataStructures

# semirings
include("semirings/semirings.jl")
include("semirings/probability.jl")
include("semirings/log.jl")
include("semirings/nlog.jl")
include("semirings/tropical.jl")
include("semirings/boolean.jl")
include("semirings/leftstring.jl")
include("semirings/rightstring.jl")
include("semirings/product.jl")
include("semirings/convert.jl")

include("epsilon.jl")
include("arc.jl")
include("wfst.jl")
include("path.jl")
include("sym.jl")
include("show.jl")
include("properties.jl")
include("other_constr.jl")
include("io_wfst.jl")

include("iterators/dfs.jl")
include("iterators/bfs.jl")
include("iterators/composeiterator.jl")

include("algorithms/allpaths.jl")
include("algorithms/rm_state.jl")
include("algorithms/is_visited.jl")
include("algorithms/get_scc.jl")
include("algorithms/connect.jl")
include("algorithms/shortest_distance.jl")
include("algorithms/permute_states.jl")
include("algorithms/topsort.jl")
include("algorithms/rm_eps.jl")
include("algorithms/determinize.jl") 
include("algorithms/arcmap.jl")
include("algorithms/inv.jl")
include("algorithms/proj.jl")
include("algorithms/reverse.jl")
include("algorithms/closure.jl")
include("algorithms/compositionfilters.jl")
include("algorithms/compose.jl")
include("algorithms/cat.jl")
include("algorithms/wfst2tr.jl")

end # module
