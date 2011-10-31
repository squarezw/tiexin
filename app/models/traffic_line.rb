class TrafficLine < ActiveRecord::Base
  TYPE_NONE=0
  TYPE_BUS=1
  TYPE_CITY_RAIL=2
  TYPES=[TYPE_BUS, TYPE_CITY_RAIL]
  TYPES_INCLUDE_NONE=[0, TYPE_BUS, TYPE_CITY_RAIL]
  N_('traffic_type|0')
  N_('traffic_type|1')
  N_('traffic_type|2')
  
  acts_as_multilingual_attribute :name
  acts_as_multilingual_attribute :introduction
  acts_as_multilingual_attribute :operation_time
  
  has_many :traffic_stops, :dependent => :delete_all, :order => :position, :include => :hot_spot 
  has_many :hot_spots, :through => :traffic_stops
  belongs_to :city

  validates_presence_of :name
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..100, :allow_nil=>true       
  validates_length_of_multilingual_attribute :introduction, :lang => XNavi::SUPPORT_LANGS, :within=>0..1000,:allow_nil=>true       
  validates_length_of_multilingual_attribute :operation_time, :lang => XNavi::SUPPORT_LANGS, :within=>0..200,:allow_nil=>true       
  

end
