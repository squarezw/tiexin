class AddContainerIdToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :container_id, :integer
    Position.find(:all).each do |pos|
      layoutable = pos.layout_map.layoutable
      if layoutable.is_a?(HotSpot)
        layoutable.hot_spots << pos.hot_spot
      end
    end
  end

  def self.down
    remove_column :hot_spots, :container_id
  end
end
