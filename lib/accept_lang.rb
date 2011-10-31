class AcceptLanguages
  attr_reader :accept_languages  
  def self.select(accept_lang_str, map={})
    AcceptLanguages.new(accept_lang_str).select(map)
  end                    
  
  def initialize(accept_lang)
    if accept_lang.nil?
      @accept_languages = []
    else
      @accept_languages=accept_lang.split(',').collect { |lang| 
        a=lang.split(';q=')
        if a.length > 1 and a.is_a?(String)
          a[1] = a[1].to_s
        else
          a[1] = 1
        end
        a
      }
      @accept_languages.sort! { |x,y| 
        x[1] <=> y[1] }
    end
  end                   
  
  def select(map={})  
    selected_lang=nil
    @accept_languages.detect { |lang|
      if k = map.keys.find { |key| Regexp.new(key).match lang[0] }
        selected_lang=map[k]
      end
      ! k.nil?
    }    
    selected_lang
  end
end
