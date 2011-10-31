module Imon      
  module DynamicQuery     
     
#      def find_by_expression(all_or_first, exp, options={})
#         conditions=expression.params
#         conditions.insert(0, exp.expression)
#         options.merge :conditions=>conditions
#         find(all_or_first, options)
#       end

    def equal(field, value)
       Imon::DynamicQuery::SimpleExpression.new field, '=', value
    end     

    def less(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '<', value
    end                                     

    def greater(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '>', value
    end

    def greater(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '>', value
    end

    def less_or_equal(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '<=', value
    end

    def greater_or_equal(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '>=', value
    end

    def like(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, 'like', "%#{value}%"
    end
    
    def in(field, values)
      raw "#{field} in (#{values.join(',')})"
    end

    def not_equal(field, value)
      Imon::DynamicQuery::SimpleExpression.new field, '<>', value
    end

    def not(exp)
      Imon::DynamicQuery::NotExpression.new(exp)
    end                             

    def is_null(field)
      Imon::DynamicQuery::IsNullExpression.new(field)                    
    end                               

    def is_not_null(field)
      not(is_null(field))
    end
    
    def between(field, low, up)
      Imon::DynamicQuery::BetweenExpression.new(field, low, up)
    end

    def and(*expressions) 
      return NullExpression if expressions.nil?
      return expressions unless expressions.is_a? Array
      Imon::DynamicQuery::CompositeExpression.new(:and, expressions)
    end  

    def or(*expressions)
      return NullExpression if expressions.nil?
      return expressions unless expressions.is_a? Array
      Imon::DynamicQuery::CompositeExpression.new(:or, expressions)
    end                 

    def exists(sub_query, *params)
      Imon::DynamicQuery::SubQuery.new(:exists, sub_query, params)
    end              
    
    def raw(exp)
      Imon::DynamicQuery::RawExpression.new exp
    end 
    
    def always_true
      Imon::DynamicQuery::TrueExpression.new
    end
     
    def always_false
      Imon::DynamicQuery::FalseExpression.new
    end

     class Expression
       def conditions
         [self.expression].concat(self.params)
       end                

       def expression
         ''
       end
       
       def params
        []
       end

       private 
       def initialize

       end
     end

     class SimpleExpression < Expression
       def initialize(field, operator, value)
         @field=field
         @operator=operator
         @value=value
       end           

       def expression
         "#{@field} #{@operator} ?"
       end 

       def params
         [@value]
       end
     end                       

     class NotExpression < Expression
       def initialize(expression)
         raise ArgumentError unless expression.is_a?(Expression)
         @expression=expression
       end          

       def expression
         "not (#{@expression.expression})"
       end                             

       def params
         @expression.params
       end
     end

     class CompositeExpression < Expression
       def initialize(operator, expressions) 
         @expressions=expressions.flatten.delete_if { |exp| exp.nil? }
         @operator=operator
       end                       

       def expression         
         return '' if @expressions.empty?
         (@expressions.collect { |exp| "(#{exp.expression})" }).join(" #{@operator} ")
       end  

       def params
         return [] if @expressions.empty?
         @expressions.inject([]) { |params, exp| params.concat(exp.params) }
       end
     end 

     class SubQuery < Expression
       def initialize(operator, query_cause, params)
         @operator=operator
         @query_cause=query_cause
         @params=params.flatten
       end                    

       def expression
         "#{@operator} (#{@query_cause})"          
       end                          

       def params
         @params          
       end
     end                   

     class IsNullExpression < Expression
       def initialize(field)
         @field=field
       end           

       def expression
         "#{@field} is null"
       end                  

       def params
         []
       end
     end
     
     class BetweenExpression < Expression
        def initialize(field, low, up)
          @field = field
          @up = up
          @low = low
        end
        
        def expression
          "#{@field} between ? and ?"
        end
        
        def params
          [@low, @up]
        end
     end
     
     class RawExpression < Expression
       def initialize(exp)
         @exp = exp
       end
       
       def expression
         "#{@exp}"
       end
       
       def params
          []
       end
     end
     
     class NullExpression < Expression
       def expression
         ''
       end
       
     end
     
     class TrueExpression < Expression
       def expression
        'true'
       end
     end

     class FalseExpression < Expression
       def expression
        'false'
       end
     end

  end #module DynamicQuery
end # module Imon

