
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

    def node_consistency? domains={}
      return true if vars.size != 1
      var=@vars.first
      domain=domains[var]
      return true if domain.all? {|value| satisfiable?(var => value) }
      return false
    end

    def eval
      raise "all variable have to be substituted before eval" unless vars.size==0
      @proc[]
    end

    def substitute hash
      oldp=@proc
      all_vars=@vars
      newp=proc do |*args|
        values = all_vars.map do |var|
          if hash.has_key? var
            hash[var]
          else
            args.shift
          end
        end
        oldp.call(*values)
      end
      new_constraint = self.class.new(*(self.vars - hash.keys),&newp)
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

