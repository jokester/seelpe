
module Seelpe
  class ConstraintSet
    def initialize logger=nil
      @constraints=[]
      @domain={}
      @indent=0
      @logger=logger
    end

    attr_reader :domain

    def log string
      if @logger
        @logger.print(string.chomp)
        @logger.print("\n")
      end
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

    def def_domain(domain_hash)
      # binding : { var => domain }
      # var can be either String or Symbol
      # domain has to be Enumerable
      raise ArgumentError "Enumberable domain expected" unless domain_hash.values.all?{|d| d.is_a? Enumerable}
      domain_hash.each do |var, domain|
        @domain[var.to_sym] = Array(domain)
      end
    end

    def satisfiable?
      raise "domain not defined for #{unrestricted_variable.join','}" unless domain_sufficent?
      back_solve Hash.new,@constraints
    end

    def reduce_domain
      # reduce domain for each constraint, until all of them are partial_solvable
      @constraints.sort_by! {|c| c.vars.size }
      still_changing=true
      iterated_times =0
      while still_changing==true
        log(pp_space_size)
        iterated_times += 1
        still_changing=false
        still_changing=@constraints.map{|c| reduce_domain_by c}.reduce(false,:|)
        #new_domains = @constraints.map{|c| reduce_domain_by c}
        #new_domains.each do |new_domain|
        #  @domain = @domain.merge(new_domain) do |var,old_domain,new_domain|
        #    if new_domain.size < old_domain.size
        #      still_changing=true
        #      new_domain
        #    else
        #      old_domain
        #    end
        #  end
        #end
      end
      size, size_product = space_size
      size_product
    end

    def space_size
      size = vars.map{|v| @domain[v].size}
      size_product = size.reduce(1,:*)
      return size, size_product
    end

    def pp_space_size
      size, size_product = space_size
      "space size is now #{size.map(&:to_s).join' x '} => #{size_product}"
    end

    def reduce_domain_by constraint
      # return whether domain was reduced by the constraint
      changed=false
      constraint.vars.each do |var|
        new_domain = @domain[var].select {|value| constraint.substitute(var=>value).satisfiable? @domain}
        if (new_domain.size < @domain[var].size)
          log "D(#{var}) reduced to #{new_domain}, once was #{@domain[var]}" 
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

