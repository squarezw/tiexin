class MoreHotSpotAttributes < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :price_level, :integer
    add_column :hot_spots, :price_memo, :string, :limit=>600
    add_column :hot_spots, :parking_slot, :integer
  end

  def self.down
    remove_column :hot_spots, :price_level
    remove_column :hot_spots, :price_memo
    remove_column :hot_spots, :parking_slot
  end
end
