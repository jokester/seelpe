# seelpe
seelpe is a ruby module to solve constraint problems on finite domain

## Example
#####to build a Constraint, you can either

build a instance by list of arguments, and a proc

    d = Constraint.new :v1,:v2 {|v1,v2| v1+v2==5}

build a subclass by Constraint.subclass, and then cast Subclass.new with argument lists

    EQ = Constraint.subclass {|a,b| a == b }
    e = EQ.new(:a,:b)

build a constraint from arithmatic expression # eval involved, DO NOT use on web server or somewhere dangerous

    f = Constraint.parse "a1+a2 < 5"


