
module Seelpe
  class ConstraintSet
    def initialize logger=nil
      @constraints=[]
      @domain={}
      @indent=0
    end

    attr_reader :domain

    def add_constraint new_constraint
      case new_constraint
      when Constraint
        @constraints << new_constraint
      when String
        @constraints << Constraint.parse(new_constraint)
      else
        raise ArgumentError "Constraint or String expected"
      end
      self # enable method chaining
    end
    alias :<< :add_constraint

    def vars
      @constraints.map(&:vars).reduce([],:concat).uniq
    end

    def def_domain(domain_hash)
      # binding : { var => domain }
      # var can be either String or Symbol
      # domain must be Enumerable
      raise ArgumentError "Enumberable domain expected" unless domain_hash.values.all?{|d| d.is_a? Enumerable}
      domain_hash.each do |var, domain|
        @domain[var.to_sym] = Array(domain)
      end
    end

    def satisfiable?
      raise "domain not defined for #{unrestricted_variable.join','}" unless domain_sufficent?
      back_solve Hash.new,@constraints
    end

    def reduce_domain &logger
      # reduce domain for each constraint, until all of them are partial_solvable
      @constraints.sort_by! {|c| c.vars.size }
      still_changing=true
      iterated_times =0
      logger||=proc {}
      while still_changing==true
        iterated_times += 1
        still_changing=@constraints.map{|c| reduce_domain_by c,&logger}.reduce(false,:|)
      end
      size, size_product = space_size
      size_product
    end

    def satisfiable?
      0 < reduce_domain
    end

    def space_size
      size = vars.map{|v| @domain[v].size}
      size_product = size.reduce(1,:*)
      return size, size_product
    end

    def space_size_to_s
      size, size_product = space_size
      "space size is now #{size.map(&:to_s).join' x '} => #{size_product}\n"
    end

    def reduce_domain_by constraint,&logger
      # return whether domain was reduced by the constraint
      raise "all domain must be defined before reduce" unless domain_sufficent?
      changed=false
      constraint.vars.each do |var|
        # reduce D(var), leave only values such that { var => value } is a partial solution
        new_domain = @domain[var].select {|value| constraint.substitute(var=>value).satisfiable? @domain}
        if (new_domain.size < @domain[var].size)
          yield "D(#{var}) has been reduced to #{new_domain}\n" if block_given?
          yield "  once was #{@domain[var]}\n" if block_given?
          @domain[var] = new_domain 
          changed=true
        end
      end
      changed
    end

    def unrestricted_variable
      vars - @domain.keys
    end

    def domain_sufficent?
      unrestricted_variable.size == 0
    end

  end # class ConstraintSet
end # module 

