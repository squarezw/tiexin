module Admin::TabooWordsHelper 
  
  def highlight_taboo_words(str)
    TabooWord.find(:all).each do |word| 
      str.gsub!(word.effective_regexp, '<span class="taboo_word">\&</span>') if word.contained_in(str)
    end                     
    return str
  end
end
