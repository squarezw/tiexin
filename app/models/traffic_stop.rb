class TrafficStop < ActiveRecord::Base
  belongs_to :traffic_line
  belongs_to :hot_spot
  acts_as_list :scope => :traffic_line 

  untranslate :position
end
