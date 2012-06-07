module Seelpe
  class Constraint
    VARIABLE_NAME = %r![a-zA-Z_][a-zA-Z_0-9]*!
    def initialize *vars, &block # block will be evaulated with substituted variables
      raise ArgumentError,"array of variable names is required"unless vars.is_a? Array
      raise ArgumentError,"block is expected" unless block_given?
      raise ArgumentError,"invalid variable name" unless vars.all?{|var| var =~ VARIABLE_NAME}
      @vars = vars.freeze
      @proc = block.freeze
    end
    attr_reader :vars

    def free_variables values
      @vars - values.keys
    end

    def full? values
      free_variables(values).size==0
    end

    def solved_by? values
      fv = free_variables values
      raise "uninstancialized variables: #{fv.join','}" unless fv.size==0
      substitute(values)
    end

    def substitute values
      args=@vars.map{|var| values[var] }
      @proc.call(*args)
    end

    def self.subclass &block # class method for a subclass
      raise "do not call this from subclass of Constraint" unless self == Constraint
      raise "block expected" unless block_given?
      Class.new(self) do
        @block = block
        def initialize *args
          blk = self.class.instance_eval{ @block }
          super *args, &blk
        end
        def self.! #overload not(Subclass)
          new_block = proc {|*args| not @block.call( *args ) }
          self.superclass.subclass &new_block
        end
      end
    end

    def self.parse string
      variable_list = string.scan(VARIABLE_NAME).map(&:to_sym).uniq
      blk = proc do |*args|
        expression = string.dup
        variable_list.each_with_index do |arg,index|
          expression.gsub!(arg.to_s,args[index].to_s)
        end
        eval expression
      end
      self.new *variable_list, &blk
    end

  end

  EQ = Constraint.subclass {|a,b| a == b }
  NE = not(EQ)
  ALL_DISTINCT = Constraint.subclass {|*args| args.uniq.size == args.size}
  HAVE_DUPLICATE = not(ALL_DISTINCT)
  GT = Constraint.subclass {|a,b| a > b }
  NGT = not(GT)
  LT = Constraint.subclass {|a,b| a < b }
  NLT = not(LT)

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
        raise ArgumentError "Constraint or expression expected"
      end
      self # enable chaining
    end
    alias :<< :add_constraint

    def vars
      @constraints.map(&:vars).reduce([],:concat).uniq
    end

    def def_domain(var,domain)
      raise ArgumentError "Enumberable domain expected" unless domain.is_a? Enumerable
      @domain[var] = domain
    end

    def solveable?
      raise "domain not defined for #{unrestricted_variable.join','}" unless domain_sufficent?
      # binding : { var => domain }
      # domain has to be Enumerable
      s = solve_recursive Hash.new
      case s
      when true
        print "solveable\n"
      else
        print "not solveable\n"
      end
    end

    def solve_recursive values
      full,notfull = @constraints.partition{|c| c.free_variables(values).size == 0}
      true
    end

    def unrestricted_variable
      vars - @domain.keys
    end

    def domain_sufficent?
      unrestricted_variable.size == 0
    end

  end # class ConstraintSet
end # module 
