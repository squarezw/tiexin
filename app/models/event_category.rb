class EventCategory < ActiveRecord::Base
  untranslate :created_at
  untranslate :updated_at
  
  acts_as_multilingual_attribute :name
  
  validates_presence_of :name
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil=>true
  
end
