class Content < ActiveRecord::Base
  belongs_to :post  
  untranslate_all
  
  validates_length_of :content, :within => 5..10000
end
