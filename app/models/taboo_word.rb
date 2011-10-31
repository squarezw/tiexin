class TabooWord < ActiveRecord::Base
  validates_presence_of :word
  validates_length_of :word, :maximum => 10
  validates_length_of :regexp, :maximum=>60, :allow_nil => true  

  def self.check(str)
    taboo_words = self.find_all_by_active true
    taboo_words.nil? or taboo_words.empty? or (taboo_words.find(){ |word| word.contained_in(str) }).nil? 
  end                
  
  def validate
    puts 'TabooWord.validate'
    begin
      Regexp.new(self.regexp) unless self.regexp.nil? or self.regexp.blank?
    rescue RegexpError => e
      errors.add :regexp, _('Invalid regular expression')
    end
    
  end
  
  def contained_in(str)
    re = self.effective_regexp    
    return  re =~ str
  end

  def effective_regexp
    if self.regexp and !self.regexp.blank?     
      return Regexp.new(self.regexp)
    elsif self.word and ! self.word.blank?
      return Regexp.new(self.word)   
    else
      return //
    end                    
  end
end
