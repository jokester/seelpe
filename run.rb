require_relative 'solver'

a = Seelpe::ConstraintSet.new
a << 'a1+a2==0' << 'a2+a3==0'
a.def_domain( :a1, [-1..1] )
a.def_domain( :a2, [-1..1] )
a.def_domain( :a3, [-1..1] )
a.solveable?
