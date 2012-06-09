# seelpe
seelpe is a ruby module to solve constraint problems on finite domain

# Example
### To build a constraint, one can either

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
