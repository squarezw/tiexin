class Hotel < ActiveRecord::Base
  belongs_to :city
  belongs_to :hot_spot
  belongs_to :category, :class_name => "HotSpotCategory", :foreign_key => :category_id
  
  has_many :hotel_rooms, :dependent=>:destroy  
  has_many :hotel_reservations, :dependent=>:destroy  
  
  validates_presence_of :address, :name, :city_id
  validates_uniqueness_of :hot_spot_id, :allow_nil => true
  
  delegate :hot_spot_category, :to => :hot_spot
  
  image_column :photo, :validate_integrity=>false, :versions=> {:mobile=>'120x80'}
  image_column :map_1, :validate_integrity=>false, :versions=> {:mobile=>'240x320'}
  image_column :map_2, :validate_integrity=>false, :versions=> {:mobile=>'240x320'}
  image_column :map_3, :validate_integrity=>false, :versions=> {:mobile=>'240x320'}
  
  before_validation { |u| 
    if u.hot_spot
      u.name = u.hot_spot.name_zh_cn if u.name.blank?
      u.address = u.hot_spot.address_zh_cn if u.address.blank?
      u.city_id = u.hot_spot.city_id if u.city_id.blank?
    end
  }
  
  def hotel_rooms_of_price(min,max)
    self.hotel_rooms.find(:all, :conditions=>['price > ? and price < ?', min, max])
  end
  
  def hotel_name
    if self.hot_spot
      return self.hot_spot.name_zh_cn
    else
      self.name
    end
  end
  
  def hotel_category_id
    if self.hot_spot
      return self.hot_spot.hot_spot_category_id
    else
      self.category_id
    end    
  end
  
  def hotel_address
    if self.hot_spot
      return self.hot_spot.address_zh_cn
    else
      self.address
    end
  end
end
