class Road < ActiveRecord::Base
  acts_as_multilingual_attribute :name
  belongs_to :city
  has_many :road_segments, :dependent=>:delete_all, :order=>'start_x, start_y, end_x, end_y'
  
  def middle_point
    return self.city.start_point if self.road_segments.empty?
    rs_size = self.road_segments.size
    if ( rs_size % 2) == 0
      rs = self.road_segments[rs_size / 2]
      return rs.end_coordinate
    elsif rs_size == 1
      return self.road_segments.first.middle_point
    else
      rs = self.road_segments[rs_size / 2 + 1]
      return rs.middle_point
    end
  end
end
