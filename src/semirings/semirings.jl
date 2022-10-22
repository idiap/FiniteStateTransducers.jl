# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

# Semiring definitions
abstract type Semiring end

import Base: zero, one, +, *, /
import Base: isapprox, parse, reverse, convert, get
isapprox(a::T,b::T) where { T <: Semiring } = isapprox(a.x,b.x)
reversetype(::Type{S}) where {S <: Semiring} = S
reverse(a::S) where { S <: Semiring } = a
reverseback(a::S) where { S <: Semiring } = a
get(a::S) where { S <: Semiring } = a.x

# properties
"""
`isleft(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a,b,c \\in \\mathbb{W} : c \\otimes(a \\oplus b) = c \\otimes a \\oplus c \\otimes b``
"""
isleft(::Type{W}) where {W} = false             # ∀ a,b,c: c*(a+b) = c*a + c*b

"""
`isright(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a,b,c \\in \\mathbb{W} : c \\otimes(a \\oplus b) = a \\otimes c \\oplus b \\otimes c``
"""
isright(::Type{W}) where {W}  = false           # ∀ a,b,c: c*(a+b) = a*c + b*c

"""
`isweaklydivisible(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a,b \\in \\mathbb{W} \\ \\text{s.t.} \\ a \\oplus b \\neq \\bar{0} \\ \\exists z : x = (x \\oplus y ) \\otimes z``
"""
isweaklydivisible(::Type{W}) where {W}  = false # a+b ≂̸ 0: ∃ z s.t. x = (x+y)*z

"""
`ispath(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a,b \\in \\mathbb{W}: a \\oplus b = a \\lor a \\oplus b = b``
"""
ispath(::Type{W}) where {W}  = false            # ∀ a,b: a+b = a or a+b=b

"""
`isidempotent(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a \\in \\mathbb{W}: a \\oplus a = a``
"""
isidempotent(::Type{W}) where {W} = false       # ∀ a: a+a = a

"""
`iscommutative(::Type{W})`

Check if the semiring type `W` satisfies:

``\\forall a,b \\in \\mathbb{W}: a \\otimes b = b \\otimes a``
"""
iscommutative(::Type{W}) where {W} = false      # ∀ a,b: a*b = b*a
iscomplete(::Type{W}) where {W} = false

Base.show(io::IO, T::Semiring) = Base.show(io, T.x)
