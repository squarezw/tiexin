require 'multilingual_attribute'

ActiveRecord::Base.class_eval do
  include Imon::Acts::MultilingualAttribute
end             

ActiveRecord::Base.send :include, Imon::Acts::MultilingualAttribute::InstanceMethods
ActionView::Base.send :include, Imon::Acts::MultilingualAttribute::Helper 
ActionController::Base.send :include, Imon::Acts::MultilingualAttribute::Helper 
ActionMailer::Base.send :include, Imon::Acts::MultilingualAttribute::Helper