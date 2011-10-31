class Position < ActiveRecord::Base
  belongs_to :hot_spot
  belongs_to :layout_map
  
  untranslate_all
  
#  validates_inclusion_of :x, :in=>0..99999999
#  validates_inclusion_of :y, :in=>0..99999999
  
  def self.exists_for?(hot_spot, layout_map)
    hot_spot_id = hot_spot.is_a?(HotSpot) ? hot_spot.id : hot_spot.to_s.to_i
    layout_map_id = layout_map.is_a?(LayoutMap) ? layout_map.id : layout_map.to_s.to_i
    self.exists?(['hot_spot_id = ? and layout_map_id = ?', hot_spot_id, layout_map_id])
  end
end
