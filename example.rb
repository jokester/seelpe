#!/usr/bin/ruby
require_relative 'seelpe'
o = Seelpe::ConstraintSet.new
o << "X<Y AND Y<Z AND Z<=2"
o.def_domain(:X => 0..3,
             :Y => 0..3,
             :Z => 0..5)
p o.satisfiable? # => true

o.def_domain(:X => 1..3,
             :Y => 0..3,
             :Z => 0..5)
p o.satisfiable? # => false

o.def_domain(:X => -1..3,
             :Y => 0..3,
             :Z => 0..5)
p o.satisfiable? # => unknown


