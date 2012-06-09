#!/usr/bin/ruby
#
require 'pp'
require_relative 'seelpe'
require 'minitest/autorun'

include Seelpe

describe Constraint do
  describe "uniary constraint" do 
    before do
      @eq = Constraint.parse "x==1"
    end

    it "is true when x==1" do
      @eq.substitute(x:1).eval.must_equal true
    end

    it "is false when x==2" do
      @eq.substitute(x:2).eval.must_equal false
    end

    it "works fine when unnecessary values are specified" do
      @eq.substitute(x:1,y:2).eval.must_equal true
    end

    it "raises exception when x is not assigned" do 
      proc{@eq.eval}.must_raise RuntimeError
    end
  end

  describe "example in README.md" do
    it "is real what we showed in README.md" do
      a = Constraint.parse "x1 < x2"
      a.vars.must_equal [:x1,:x2] 

      b = a.substitute( x1: 5 )
      b.vars.must_equal [:x2]

      c = b.substitute( x2: 6 )
      c.vars.must_equal [] 
      c.eval.must_equal true

      d = a.substitute( x1:5, x2:3 )
      d.eval.must_equal false
    end
  end

  describe "binary constraint" do
    before do
      @x_plus_y_eq_2 = Constraint.parse(' x+y==2')
    end

    it "is true when x+y==2" do
      @x_plus_y_eq_2.substitute(x:-1,y:3).eval.must_equal true
    end

    it "is false when x+y!=2" do
      @x_plus_y_eq_2.substitute(x:0,y:1).eval.must_equal false
    end

    it "is still true when x=0 and y=2 are separately substituted" do
      @x_plus_y_eq_2.substitute(x:0).substitute(y:2).eval.must_equal true
    end

    it "is still true when x=-1 and y=3 are separately substituted in another order" do
      @x_plus_y_eq_2.substitute(y:3).substitute(x:-1).eval.must_equal true
    end

  end
end

describe ALL_DISTINCT do






end
