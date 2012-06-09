require_relative 'solver'
require 'pp'

class Queen < Seelpe::ConstraintSet
  def initialize( rows,cols,queens )
    super()

    # no 2 queens share same row
    row_vars = (1..queens).map {|_| "r#{_}" }
    add_constraint Seelpe::ALL_DISTINCT.new(*row_vars)

    # no 2 queens share same col
    col_vars = (1..queens).map {|_| "c#{_}" }
    add_constraint Seelpe::ALL_DISTINCT.new(*col_vars)

    # no 2 queens share same diagonal
#    Array(1..queens).combination(2) do |q1,q2|
#      add_constraint "r#{q1} - r#{q2} != c#{q1} - c#{q2}"
#      add_constraint "r#{q1} + c#{q1} != r#{q2} + c#{q2}"
#    end

    # domain
    1.upto queens do |q|
      def_domain "r#{q}", 1..rows
      def_domain "c#{q}", 1..cols
    end
  end
end

q1 = Queen.new(4,4,1)
p q1.satisfiable?

