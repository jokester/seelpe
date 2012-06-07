require_relative 'solver'
require 'minitest/autorun'

include ConstraintSolver

describe EQ do
  before do
    @eq = EQ.new( :arg1, :arg2 )
  end

  it "succeeds when equal" do
    @eq.solved_by?( arg1:1, arg2:1 ).must_equal true
  end

  it "fails when inequal" do
    @eq.solved_by?( arg1:5, arg2:3 ).must_equal false
  end

  it "should throw exception" do
    proc{@eq.solved_by?( arg2:100)}.must_raise(RuntimeError)
  end
end

describe NE do
  before do
    @c = NE.new( :arg1, :arg2 )
  end

  it "succeeds when inequal" do
    @c.solved_by?( arg1:2, arg2:1 ).must_equal true
  end

  it "fails when equal" do
    @c.solved_by?( arg1:3, arg2:3 ).must_equal false
  end

  it "should throw exception" do
    proc{@c.solved_by?( arg3:100)}.must_raise(RuntimeError)
  end
end

describe ALL_DISTINCT do
  before do
    @c = ALL_DISTINCT.new( :a, :b, :c)
  end

  it "succeeds when all distinct" do
    @c.solved_by?( a:1, b:2, c:5 ).must_equal true
  end

  it "fails when some of them duplicate" do
    @c.solved_by?( a:1, b:1, c:2).must_equal false
  end

  it "should throw exception" do
    proc{@c.solved_by?( arg2:5) }.must_raise RuntimeError
  end
end

describe Constraint do
  before do
    @c = Constraint.parse "a1+a2 < 5"
  end

  it "should be right" do
    @c.solved_by?( a1:1, a2:2).must_equal true
  end

  it "should be false" do
    @c.solved_by?( a2:5, a1:0).must_equal false
  end

  it "should still be right" do
    @c.solved_by?( a1:1, a2:2).must_equal true
  end

  it "should throw exception" do
    proc{@c.solved_by?(a1:5) }.must_raise RuntimeError
  end
end

describe Constraint do
  before do
    @d = Constraint.new(:v1,:v2) {|v1,v2| v1+v2==5}
  end

  it "should be right" do
    @d.solved_by?( v1:1, v2:4).must_equal true
  end

  it "should be false" do
    @d.solved_by?( v2:2, v1:2).must_equal false
  end
end

describe ConstraintSet do
  before do
    @set = ConstraintSet.new
    @set.add_constraint( EQ.new(:a1,:a2) )
    @set.add_constraint( GT.new(:a2,:a3) )
    @set.add_constraint 'a1 +a2 == a3+a4'
  end

  it "should get correct vars" do
    @set.vars.sort.must_equal [:a1,:a2,:a3,:a4].sort
  end

  it "should get right domain" do
    @set.def_domain(:a1, 1..5)
    @set.def_domain(:a2, 1..5)
    @set.def_domain(:a3, 1..5)
    @set.def_domain(:a4, 1..5)
    @set.domain_sufficent?.must_equal true
  end

  it "should throw when domain is not enough" do
    @set.def_domain(:a2, 1..5)
    @set.def_domain(:a3, 1..5)
    @set.def_domain(:a4, 1..5)
    proc{@set.solveable? }.must_raise(RuntimeError)
  end
end

