class District < ActiveRecord::Base
  belongs_to :city
  
  acts_as_multilingual_attribute :name
  
  validates_presence_of :name
  
end
