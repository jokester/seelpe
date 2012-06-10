# seelpe
seelpe is a ruby module to solve constraint problems on finite domain

# Example
## To build a constraint, one can either

* build a instance by list of arguments, and a proc

        d = Constraint.new :v1,:v2 {|v1,v2| v1+v2==5}

* build a subclass by `Constraint.subclass`, and then cast `Subclass.new` with argument lists

        EQ = Constraint.subclass {|a,b| a == b }
        e = EQ.new(:a,:b)

* build a constraint from arithmatic expression. `eval` is involved here, **DO NOT** use on web server or somewhere dangerous

        f = Constraint.parse "a1+a2 < 5"

* such a subclass responds to `:!` , which returns another subclass of `Constraint`

        ALL_DISTINCT = Constraint.subclass {|*args| args.uniq.size == args.size}
        HAVE_DUPLICATE = not(ALL_DISTINCT)

### With a constraint, one can

        a = Constraint.parse "x1 < x2"

* check its variable

        a.vars # => [:x1, :x2]

* generate another constraint, by valuating some of its variables

        b = a.substitute( x1: 5 )
        b.vars # => [:x2]

* with all variables valuated, we can eval constraint like

        c = b.substitute( x2: 6 )
        c.vars # => []
        c.eval # => true

* or

        d = a.substitute( x1:5, x2:3 )
        d.eval # => false

## To build a constraint set

###simply `ConstraintSet.new`, and feed it with constriants

        s = Seelpe::ConstraintSet.new
        s << "x + y == 16" << "2*x + 4*y == 44"
        # x => num of cranes
        # y => num of tortoises
        # 16 heads and 44 legs in total

* A constraint set is actually a horn clause.

* It can be used to reduce a set of domains, and determine if any solution exists on the domain

        s.def_domain(:x => 0..10,
                     :y => 0..10)

        s.reduce_domain {|line| print line} # log string will be yielded, if a block is given
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

