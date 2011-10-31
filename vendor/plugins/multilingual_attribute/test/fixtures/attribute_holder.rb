class AttributeHolder < ActiveRecord::Base
  acts_as_multilingual_attribute :name 
  validates_presence_of :name
end

