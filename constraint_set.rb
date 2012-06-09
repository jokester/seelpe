
module Seelpe
  class ConstraintSet
    def initialize
      @constraints=[]
      @domain={}
      @indent=0
    end

    def add_constraint new_constraint
      case new_constraint
      when Constraint
        @constraints << new_constraint
      when String
        @constraints << Constraint.parse(new_constraint)
      else
        raise ArgumentError "Constraint or String expected"
      end
      self # enable chaining
    end
    alias :<< :add_constraint

    def vars
      @constraints.map(&:vars).reduce([],:concat).uniq
    end

    def def_domain(var,domain)
      # binding : { var => domain }
      # domain has to be Enumerable
      raise ArgumentError "Enumberable domain expected" unless domain.is_a? Enumerable
      @domain[var.to_sym] = domain
    end

    def satisfiable?
      raise "domain not defined for #{unrestricted_variable.join','}" unless domain_sufficent?
      back_solve Hash.new,@constraints
    end

    def reduce_domain
      @constraints.sort_by! {|c| c.vars.size }
      result = [true]
      while result.any?
        result = @constraints.map {|c| reduce_domain_by c}
      end
    end

    def reduce_domain_by constraint
      # return true when domain is reduced
      #vars = constraint.

    end

    def partial_satisfiable? values
      if @constraints.any?{|c| not c.satisfiable?(values)}
        return false
      else
        return true
      end
    end

    def back_solve values,constraints
      vars = constraints.reduce([]) {|a,c| a.concat c.not_valuated(values)}
      return partial_satisfiable?(values) if vars.size==0

      x = vars.first
      #TODO optimize selection of x 

      @domain[x].any? do |val_for_x|
        val_new = values.dup
        val_new[x]=val_for_x
        partial_satisfiable?(val_new) and back_solve(val_new,constraints)
      end
    end

    def unrestricted_variable
      vars - @domain.keys
    end

    def domain_sufficent?
      unrestricted_variable.size == 0
    end

  end # class ConstraintSet
end # module 



