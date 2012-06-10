#!/usr/bin/ruby
require_relative 'seelpe'

s = Seelpe::ConstraintSet.new

s << "x + y == 16" << "2*x + 4*y == 44"
# x => num of cranes
# y => num of tortoises
# 16 heads in total

s.def_domain(:x => 0..10,
             :y => 0..10)

s.reduce_domain {|line| print line}
# => 
# D(x) has been reduced to [6, 7, 8, 9, 10]
#   once was [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# D(y) has been reduced to [6, 7, 8, 9, 10]
#   once was [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# D(x) has been reduced to [6, 8, 10]
#   once was [6, 7, 8, 9, 10]
# D(y) has been reduced to [6, 7, 8]
#   once was [6, 7, 8, 9, 10]
# D(x) has been reduced to [8, 10]
#   once was [6, 8, 10]
# D(y) has been reduced to [6, 8]
#   once was [6, 7, 8]
# D(x) has been reduced to [10]
#   once was [8, 10]
# D(y) has been reduced to [6]
#   once was [6, 8]

print s.satisfiable?,"\n"
# => true

s.def_domain(:x => 0..5,
             :y => 0..3)

print s.satisfiable?,"\n"
# => false


