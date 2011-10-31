require 'coordinate'

class RoadSegment < ActiveRecord::Base
  untranslate_all
  belongs_to :road
  
  def start_coordinate=(coordinate)
    self.start_x = coordinate.x
    self.start_y = coordinate.y
  end

  def start_coordinate
    XNavi::Coordinate.new self.start_x, self.start_y
  end
  
  def end_coordinate=(coordinate)
    self.end_x = coordinate.x
    self.end_y = coordinate.y
  end
  
  def end_coordinate
    XNavi::Coordinate.new(self.end_x, self.end_y)
  end
  
  def middle_point
    XNavi::Coordinate.new((self.start_x + self.end_x) / 2, (self.start_y + self.end_y)/ 2)
  end
end
