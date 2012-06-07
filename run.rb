require_relative 'solver'
require "pp"

a = Seelpe::ConstraintSet.new
a << 'a1+a2==0' << 'a2+a3==0'
a.def_domain( :a1, -1..1 )
a.def_domain( :a2, -1..1 )
a.def_domain( :a3, -1..1 )
if a.solveable?
  print "it is solvable\n"
else
  print "it is not solvable\n"
end

a << '1==0'
if a.solveable?
  print "it is solvable\n"
else
  print "it is not solvable\n"
end

