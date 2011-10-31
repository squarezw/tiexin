module  Imon    
  module Acts
    module MultilingualAttribute  
      def self.included(base)
        base.extend(ClassMethods)
      end                        
      
      module ClassMethods      
        def acts_as_multilingual_attribute(attr_name)
          attr_name = attr_name.to_sym
          
          define_method(attr_name) do
            attr_value= self.multilingual_attributes[attr_name]
            attr_value.nil? ? (multilingual_attributes[attr_name]=Proxy.new(attr_name, self)) : attr_value
          end  
          
          define_method(attr_name.to_s + '=') do |value_hash|
            self.send(attr_name).set_values(value_hash)
          end       
        end # acts_as_multilingual_attribute
                                            
        def validates_length_of_multilingual_attribute(*attr)
          options={:lang=>['zh_CN'] } 
          options.update(attr.pop) if attr.last.is_a?(Hash)
          real_attrs = attr.inject([]) { |names, a_name| 
            options[:lang].inject(names) { |names2, lang|
              names2 << "#{a_name}_#{lang}"
              names2
            }       
            names
          }                       
          validates_length_of real_attrs, options
        end             
       
      end # module ClassMethods 
      
      module InstanceMethods      
        def multilingual_attributes
          @multilingual_attributes ||= Hash.new()
        end
      end # module InstanceMethods  
      
      module Helper      
        def localized_description(object, method=nil)
          return '' if object.nil?
          unless method.nil? or method.blank?
            object=object.send(method) if object.respond_to?(method)
          end                            
          lang = @current_lang || 'zh_cn'  
          if object.respond_to? :safe_value_for_lang
            result = object.safe_value_for_lang lang            
          else
            result = object[lang]            
          end
          result.nil? ? '' : result
        end               
        
        def localized_descriptions(collection, method=nil)
          (collection.collect { |item| localized_description(item, method) }).join(',')
        end
      end # module Helper
                           
                          
      class Proxy
        def initialize(attr_name, record)
          @attr_name= attr_name
          @record= record
        end              
                        
        def [](lang)
          get(lang.to_s)
        end                       
        
        def []=(lang, value)
          set(lang.to_s, value)
        end
        
        def set_values(values)
          values.each_pair { |key, value| set(key.to_s, value) }
        end
        
        def strip!
          @record.attributes.each_pair  { |key, value|
            if key=~ Regexp.new("#{@attr_name}_([\\w_]+)$")
              @record[key] = value.strip unless value.nil?
            end
          }                          
        end
        
        def method_missing(method_name, *args)
          method_name = method_name.to_s
          raise NoMethodError,"Method '#{method_name}' has not been defined." unless method_name =~ /(\w|=)$/   
          begin
            if method_name =~ /=$/
              set(method_name, args[0])
            else                   
              get(method_name)
            end
          rescue ArgumentError
            raise NoMethodError, "Method '#{method_name}' has not been defined."
          end
        end          
        
        def respond_to?(method_name)  
          super or @record.respond_to?("#{@attr_name}_#{method_name}")
        end
                       
        def all_lang
          result=Hash.new
          @record.attributes.each_pair  { |key, value|
            if key=~ Regexp.new("#{@attr_name}_([\\w_]+)$")
              result[$1.to_sym]=value
            end
          }                          
          result
        end
        
        def blank?
          all_lang.select { |name, value|
            ( ! value.nil?) && ( ! value.blank? ) 
          }.empty?
        end           
        
        def safe_value_for_lang(lang)
          result = get(lang)
          if (result.nil? or result.blank?)
            non_empty_values=self.all_lang.values.select {|value| ! (value.nil? or value.blank?) }
            result=non_empty_values[0] unless non_empty_values.empty?
          end 
          result.nil? ? '' : result
        end
        
        private
        
        def set(lang, value)  
          lang += '=' unless lang =~ /=$/
          setter="#{@attr_name}_#{lang}" 
          if @record.respond_to?(setter)
            @record.send(setter, value) 
          else
            raise ArgumentError, "Language #{lang} is not supported."
          end
        end                                                         
        
        def get(lang)    
          getter="#{@attr_name}_#{lang}"
          return @record.send(getter) if @record.respond_to?(getter)
          raise ArgumentError, "Language #{lang} is not supported"
        end
      end # class Proxy
      
    end
  end # module Acts
end # module Imon