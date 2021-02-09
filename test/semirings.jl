# Copyright (c) 2021 Idiap Research Institute, http://www.idiap.ch/
#  Niccolò Antonello <nantonel@idiap.ch>

for T in [Float64, Float32]

  #################
  # ProbabilityWeight semiring
  #################
  a = ProbabilityWeight(rand(T)) 
  b = ProbabilityWeight(rand(T)) 
  c = ProbabilityWeight(rand(T)) 
  d = ProbabilityWeight{T}(a) # check ProbabilityWeight(x::ProbabilityWeight)
  e = ProbabilityWeight{T}( ProbabilityWeight{T == Float64 ? Float32 : Float64}(get(a)) )
  f = ProbabilityWeight{T}( rand(T == Float64 ? Float32 : Float64) )
  @test typeof(e) == ProbabilityWeight{T}
  @test typeof(f) == ProbabilityWeight{T}

  @test (a*b).x == a.x*b.x
  @test (a + b).x == a.x + b.x
  @test (a/b).x == a.x/b.x
  @test reverse(a) == a
  @test FiniteStateTransducers.reverseback(a) == a
  o = one(ProbabilityWeight{T})
  @test o.x  == one(T)
  z = zero(ProbabilityWeight{T})
  @test z.x == zero(T)

  # + commutative monoid
  @test (a+b)+c ≈ a+(b+c)
  @test a+z ≈ z+a ≈ a
  @test a+b ≈ b+a 
  # * monoid
  @test (a*b)*c ≈ a*(b*c)
  @test a*o == o*a == a # identity
  @test a*z == z*a == z # annihilator
  # distribution over addition
  @test a*(b+c) ≈ (a*b)+(a*c)
  @test (a+b)*c ≈ (a*c)+(b*c)
  # division 
  c = a*b
  @test a*(c/a) ≈ c
  @test (c/b)*b ≈ c

  # properties
  W = ProbabilityWeight{T}
  @test FiniteStateTransducers.isidempotent(W) == false
  @test FiniteStateTransducers.iscommulative(W)
  @test FiniteStateTransducers.isleft(W)
  @test FiniteStateTransducers.isright(W)
  @test FiniteStateTransducers.isweaklydivisible(W)
  @test FiniteStateTransducers.iscomplete(W)
  @test FiniteStateTransducers.ispath(W) == false
  @test FiniteStateTransducers.reversetype(W) == W

  a = parse(W,"1.0")
  @test a.x == T(1.0)

  #################
  # LogWeight semiring
  #################
  a = LogWeight(1) 
  b = LogWeight(2) 
  @test (a + b).x ≈ log(exp(a.x)+exp(b.x)) 

  a = LogWeight(2) 
  b = LogWeight(1) 
  @test (a + b).x ≈ log(exp(a.x)+exp(b.x)) 

  a = LogWeight(rand(T)) 
  b = LogWeight(rand(T)) 
  c = LogWeight(rand(T)) 
  d = LogWeight{T}(a) # check ProbabilityWeight(x::ProbabilityWeight)
  e = LogWeight{T}( LogWeight{T == Float64 ? Float32 : Float64}(get(a)) )
  @test typeof(e) == LogWeight{T}

  @test (a*b).x ≈ a.x + b.x
  @test (a + b).x ≈ log(exp(a.x)+exp(b.x)) 
  @test (a / b).x ≈ log(exp(a.x)/exp(b.x)) 
  @test reverse(a) == a
  @test FiniteStateTransducers.reverseback(a) == a
  o = one(LogWeight{T})
  @test o.x  == 0
  z = zero(LogWeight{T})
  @test z.x == T(log(0))

  # + commutative monoid
  @test (a+b)+c ≈ a+(b+c)
  @test a+z ≈ z+a ≈ a
  @test a+b ≈ b+a 
  # * monoid
  @test (a*b)*c ≈ a*(b*c)
  @test a*o == o*a == a # identity
  @test a*z == z*a == z # annihilator
  # distribution over addition
  @test a*(b+c) ≈ (a*b)+(a*c)
  @test (a+b)*c ≈ (a*c)+(b*c)
  # division 
  c = a*b
  @test a*(c/a) ≈ c
  @test (c/b)*b ≈ c

  # properties
  W = LogWeight{T}
  @test FiniteStateTransducers.isidempotent(W) == false
  @test FiniteStateTransducers.iscommulative(W)
  @test FiniteStateTransducers.isleft(W)
  @test FiniteStateTransducers.isright(W)
  @test FiniteStateTransducers.isweaklydivisible(W)
  @test FiniteStateTransducers.iscomplete(W)
  @test FiniteStateTransducers.ispath(W) == false
  @test FiniteStateTransducers.reversetype(W) == W

  # parse
  a = parse(W,"1.0")
  @test a.x == T(1.0)

  #################
  # NLogWeight semiring
  #################
  a = NLogWeight(1) 
  b = NLogWeight(2) 
  @test (a + b).x ≈ -log(exp(-a.x)+exp(-b.x)) 

  a = NLogWeight(2) 
  b = NLogWeight(1) 
  @test (a + b).x ≈ -log(exp(-a.x)+exp(-b.x)) 

  a = NLogWeight(rand(T)) 
  b = NLogWeight(rand(T)) 
  c = NLogWeight(rand(T)) 
  d = NLogWeight{T}(a) # check ProbabilityWeight(x::ProbabilityWeight)
  e = NLogWeight{T}( NLogWeight{T == Float64 ? Float32 : Float64}(get(a)) )
  @test typeof(e) == NLogWeight{T}

  @test (a*b).x ≈ a.x + b.x
  @test (a + b).x ≈ -log(exp(-a.x)+exp(-b.x)) 
  @test (a / b).x ≈ log(exp(a.x)/exp(b.x)) 
  @test reverse(a) == a
  @test FiniteStateTransducers.reverseback(a) == a
  o = one(NLogWeight{T})
  @test o.x  == 0
  z = zero(NLogWeight{T})
  @test z.x == T(-log(0))

  # + commutative monoid
  @test (a+b)+c ≈ a+(b+c)
  @test a+z ≈ z+a ≈ a
  @test a+b ≈ b+a 
  # * monoid
  @test (a*b)*c ≈ a*(b*c)
  @test a*o == o*a == a # identity
  @test a*z == z*a == z # annihilator
  # distribution over addition
  @test a*(b+c) ≈ (a*b)+(a*c)
  @test (a+b)*c ≈ (a*c)+(b*c)
  # division 
  c = a*b
  @test a*(c/a) ≈ c
  @test (c/b)*b ≈ c

  # properties
  W = NLogWeight{T}
  @test FiniteStateTransducers.isidempotent(W) == false
  @test FiniteStateTransducers.iscommulative(W)
  @test FiniteStateTransducers.isleft(W)
  @test FiniteStateTransducers.isright(W)
  @test FiniteStateTransducers.isweaklydivisible(W)
  @test FiniteStateTransducers.iscomplete(W)
  @test FiniteStateTransducers.ispath(W) == false
  @test FiniteStateTransducers.reversetype(W) == W

  # parse
  a = parse(W,"1.0")
  @test a.x == T(1.0)

  #################
  # TropicalWeight semiring
  #################
  a = TropicalWeight(rand(T)) 
  b = TropicalWeight(rand(T)) 
  c = TropicalWeight(rand(T)) 
  d = TropicalWeight{T}(a) # check ProbabilityWeight(x::ProbabilityWeight)
  e = TropicalWeight{T}( TropicalWeight{T == Float64 ? Float32 : Float64}(get(a)) )
  @test typeof(e) == TropicalWeight{T}

  @test (a*b).x == a.x + b.x
  @test (a + b).x == min(a.x,b.x) 
  @test (a / b).x ≈ log(exp(a.x)/exp(b.x)) 
  o = one(TropicalWeight{T})
  @test o.x  == 0
  z = zero(TropicalWeight{T})
  @test z.x == T(Inf)

  # + commutative monoid
  @test (a+b)+c ≈ a+(b+c)
  @test a+z ≈ z+a ≈ a
  @test a+b ≈ b+a 
  # * monoid
  @test (a*b)*c ≈ a*(b*c)
  @test a*o == o*a == a # identity
  @test a*z == z*a == z # annihilator
  # distribution over addition
  @test a*(b+c) ≈ (a*b)+(a*c)
  @test (a+b)*c ≈ (a*c)+(b*c)
  # division 
  c = a*b
  @test a*(c/a) ≈ c
  @test (c/b)*b ≈ c

  W = TropicalWeight{T}
  @test FiniteStateTransducers.isidempotent(W)
  @test FiniteStateTransducers.iscommulative(W)
  @test FiniteStateTransducers.isleft(W)
  @test FiniteStateTransducers.isright(W)
  @test FiniteStateTransducers.isweaklydivisible(W)
  @test FiniteStateTransducers.iscomplete(W)
  @test FiniteStateTransducers.ispath(W)
  @test FiniteStateTransducers.reversetype(W) == W

  # parse
  a = parse(W,"1.0")
  @test a.x == T(1.0)
end

a = BoolWeight(rand([true;false])) 
b = BoolWeight(rand([true;false])) 
c = BoolWeight(rand([true;false])) 
d = BoolWeight(a) # check ProbabilityWeight(x::ProbabilityWeight)

@test (a*b).x == ( a.x && b.x)
@test (a + b).x == ( a.x || b.x )
o = one(BoolWeight)
@test o.x  == true
z = zero(BoolWeight)
@test z.x == false
@test_throws MethodError a/b

# + commutative monoid
@test (a+b)+c ≈ a+(b+c)
@test a+z ≈ z+a ≈ a
@test a+b ≈ b+a 
# * monoid
@test (a*b)*c ≈ a*(b*c)
@test a*o == o*a == a # identity
@test a*z == z*a == z # annihilator
# distribution over addition
@test a*(b+c) ≈ (a*b)+(a*c)
@test (a+b)*c ≈ (a*c)+(b*c)

W = BoolWeight
@test FiniteStateTransducers.isidempotent(W)
@test FiniteStateTransducers.iscommulative(W)
@test FiniteStateTransducers.isleft(W)
@test FiniteStateTransducers.isright(W)
@test FiniteStateTransducers.isweaklydivisible(W) == false
@test FiniteStateTransducers.ispath(W)
@test FiniteStateTransducers.reversetype(W) == W

a = parse(W,"1")
@test a.x == true

########################### 
########################### 
########################### 

a = LeftStringWeight("ciao") 
b = LeftStringWeight("caro") 
c = LeftStringWeight("mona") 
d = LeftStringWeight(a) # check ProbabilityWeight(x::ProbabilityWeight)

@test (a*b).x == "ciaocaro"
@test (a*c).x == "ciaomona"
@test (a + b).x == "c"
@test (a + c).x == ""

o = one(LeftStringWeight)
@test o.x  == ""
@test o.iszero  == false
z = zero(LeftStringWeight)
@test z.x == ""
@test z.iszero

# + commutative monoid
@test (a+b)+c == a+(b+c)
@test a+z == z+a == a
@test a+b == b+a 
# * monoid
@test (a*b)*c == a*(b*c)
@test a*o == o*a == a # identity
@test a*z == z*a == z # annihilator
# distribution over addition
@test a*(b+c) == (a*b)+(a*c)
# division 
c = a*b
@test a*(c/a) == c
@test (c/b)*b != c

W = LeftStringWeight
@test FiniteStateTransducers.isidempotent(W)
@test FiniteStateTransducers.iscommulative(W) == false
@test FiniteStateTransducers.isleft(W)
@test FiniteStateTransducers.isright(W) == false
@test FiniteStateTransducers.isweaklydivisible(W)
@test FiniteStateTransducers.ispath(W) == false
@test FiniteStateTransducers.reversetype(W) == RightStringWeight

########################### 
########################### 
########################### 

a = RightStringWeight("ciao") 
b = RightStringWeight("caro") 
c = RightStringWeight("mona") 
d = RightStringWeight(a) # check ProbabilityWeight(x::ProbabilityWeight)

@test (a*b).x == "ciaocaro"
@test (a*c).x == "ciaomona"
@test (a + b).x == "o"
@test (a + c).x == ""

o = one(RightStringWeight)
@test o.x  == ""
@test o.iszero == false
z = zero(RightStringWeight)
@test z.x == ""
@test z.iszero

# + commutative monoid
@test (a+b)+c == a+(b+c)
@test a+z == z+a == a
@test a+b == b+a 
# * monoid
@test (a*b)*c == a*(b*c)
@test a*o == o*a == a # identity
@test a*z == z*a == z # annihilator
# distribution over addition
@test (a+b)*c == (a*c)+(b*c)
# division 
c = a*b
@test a*(c/a) != c
@test (c/b)*b == c

W = RightStringWeight
@test FiniteStateTransducers.isidempotent(W)
@test FiniteStateTransducers.iscommulative(W) == false
@test FiniteStateTransducers.isleft(W) == false
@test FiniteStateTransducers.isright(W)
@test FiniteStateTransducers.isweaklydivisible(W)
@test FiniteStateTransducers.ispath(W) == false
@test FiniteStateTransducers.reversetype(W) == LeftStringWeight

########################### 
########################### 
########################### 

W1, W2 = LeftStringWeight, TropicalWeight{Float64}
a = ProductWeight(W1("ciao"),W2(1.0))
b = ProductWeight(W1("caro"),W2(2.0))
c = ProductWeight(W1("mona"),W2(3.0))
d = ProductWeight(a) # check ProbabilityWeight(x::ProbabilityWeight)
dd = typeof(d)(a)

@test (a*b) == ProductWeight(W1("ciaocaro"),W2(3.0))
@test (a*c) == ProductWeight(W1("ciaomona"),W2(4.0))
@test (a+b) == ProductWeight(W1("c"),W2(1.0))
@test (a+c) == ProductWeight(W1(""),W2(1.0))

W = typeof(a)
o = one(W)
@test get(o)[1]  == one(W1)
@test get(o)[2]  == one(W2)
z = zero(typeof(a))
@test get(z)[1] == zero(W1)
@test get(z)[2] == zero(W2)

# + commutative monoid
@test (a+b)+c == a+(b+c)
@test a+z == z+a == a
@test a+b == b+a 
# * monoid
@test (a*b)*c == a*(b*c)
@test a*o == o*a == a # identity
@test a*z == z*a == z # annihilator
# distribution over addition
@test a*(b+c) == (a*b)+(a*c)
# division 
c = a*b
@test a*(c/a) == c

@test FiniteStateTransducers.isidempotent(W)
@test FiniteStateTransducers.iscommulative(W) == false
@test FiniteStateTransducers.isleft(W)
@test FiniteStateTransducers.isright(W) == false
@test FiniteStateTransducers.isweaklydivisible(W)
@test FiniteStateTransducers.ispath(W) == false
@test FiniteStateTransducers.reversetype(W) == ProductWeight{2,Tuple{RightStringWeight,TropicalWeight{Float64}}}
