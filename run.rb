require_relative 'solver'

a = ConstraintSolver::ConstraintSet.new
a << 'a1+a2==0' << 'a2+a3==0' << 'a3+a4==0' 

a.solveable?
