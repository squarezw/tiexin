class AddRecommendFieldToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :recommend, :boolean, :default => false
    add_column :hot_spots, :recommend_expire_at, :datetime
  end

  def self.down
    remove_column :hot_spots, :recommend
    remove_column :hot_spots, :recommend_expire_at
  end
end
