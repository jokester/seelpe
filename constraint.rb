
module Seelpe
  class Constraint
    VARIABLE_NAME = %r![a-zA-Z_][a-zA-Z_0-9]*!
    def initialize *vars, &block # block will be evaulated with substituted variables
      raise ArgumentError,"array of variable names is required"unless vars.is_a? Array
      raise ArgumentError,"block is expected" unless block_given?
      raise ArgumentError,"invalid variable name in #{vars}" unless vars.all?{|var| var =~ VARIABLE_NAME}
      @vars = vars.map(&:to_sym).freeze
      @proc = block.freeze
    end
    attr_reader :vars

    def not_valuated values
      @vars - values.keys
    end

    def all_valuated? values
      not_valuated(values).size==0
    end

    def satisfiable? values
      fv = not_valuated values
      if fv.size==0
        substitute(values)
      else
        false
      end

      #raise "uninstancialized variables: #{fv.join','}" unless fv.size==0
    end

    def substitute values
      args=@vars.map{|var| values[var] }
      @proc.call(*args)
    end

    def node_consistency? domains
      return true if vars.size != 1
      var=vars.first
      domain=domains[var]
      return true if domain.all? do |value|
        satisfiable?( var => value )
      end

      return false
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

end # module 

