# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

using FiniteStateTransducers
using Test, Random
using DataStructures
Random.seed!(123)

@testset "FiniteStateTransducers.jl" begin
  @testset "Semirings" begin
    include("semirings.jl")
  end
  @testset "FiniteStateTransducers constructors and utils" begin
    include("wfst.jl")
    include("properties.jl")
    include("io_wfst.jl")
  end
  @testset "algorithms" begin
    include("paths.jl") #Paths, BFS, paths
    include("dfs.jl") #rm_state, DFS, get_scc, connect, rm_eps
    include("shortest_distance.jl")
    include("topsort.jl")
    include("rm_eps.jl")
    include("closure.jl")
    include("inv.jl")
    include("proj.jl")
    include("reverse.jl")
    include("compose.jl")
    include("cat.jl")
    include("determinize.jl")
    include("wfst2tr.jl")
  end
end

#@testset "FiniteStateTransducers.jl" begin
#end
