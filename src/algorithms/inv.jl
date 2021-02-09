# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

"""
`inv(fst::WFST)`

Inverts `fst` such that input labels are swaped with output labels.
"""
function Base.inv(fst::WFST)
  ifst = arcmap(inv, fst)
  ifst = WFST(ifst.states,ifst.initials,ifst.finals,ifst.osym,ifst.isym)
  return ifst 
end

