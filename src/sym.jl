# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

export get_isym
"""
`get_isym(fst::WFST)`

Returns the input symbol table of `fst`. The table consists of a dictionary where each element goes from the symbol to the corresponding index.
"""
get_isym(fst::Union{WFST,Path}) = fst.isym

export get_iisym
"""
`get_iisym(fst::WFST)`

Returns the inverted input symbol table.
"""
get_iisym(fst::Union{WFST,Path}) = Dict(fst.isym[k] => k for k in keys(fst.isym))

export get_osym
"""
`get_osym(fst::WFST)`

Returns the output symbol table of `fst`. The table consists of a dictionary where each element goes from the symbol to the corresponding index. 
"""
get_osym(fst::Union{WFST,Path}) = fst.osym

export get_iosym
"""
`get_iosym(fst::WFST)`

Returns the inverted output symbol table.
"""
get_iosym(fst::Union{WFST,Path}) = Dict(fst.osym[k] => k for k in keys(fst.osym))
