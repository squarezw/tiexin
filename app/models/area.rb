require 'coordinate'

class Area < ActiveRecord::Base                 
  untranslate :city, :nw_x, :nw_y, :width, :height
  acts_as_multilingual_attribute :name     
  belongs_to :city
                             
  validates_presence_of :name
  validates_presence_of :city
  validates_presence_of :nw_x
  validates_presence_of :nw_y
  validates_presence_of :height
  validates_presence_of :width
  
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil=>true   
  
  def center
    XNavi::Coordinate.new(nw_x + width / 2, nw_y + height / 2)
  end
  
  def se_x
    self.nw_x + self.width
  end
  
  def se_y
    self.nw_y + self.height
  end
  
  def before_save
    c = self.center
    self.center_x, self.center_y = c.x, c.y
  end
  
  def nearby_areas(limit=5)
    rows = Area.connection.select_all(
<<SQL
    select a1.id, distance(a1.center_x, a1.center_y, a2.center_x, a2.center_y) dist
    from areas a1, areas a2
    where a1.city_id = a2.city_id
    	  and a2.id = #{self.id}
    	  and a1.id <> a2.id
    order by dist
    limit #{limit};
SQL
    )
    rows.collect { |row| Area.find row['id'] }
  end
  
  def visited!
    self.update_attribute_with_validation_skipping :visit_count, self.visit_count + 1
  end
  
  def contains?(hot_spot)
    self.city_id == hot_spot.city_id and 
    self.nw_x <= hot_spot.x and 
    self.nw_y <= hot_spot.y and 
    self.nw_x + self.width >= hot_spot.x and
    self.nw_y + self.height >= hot_spot.y
  end
end
