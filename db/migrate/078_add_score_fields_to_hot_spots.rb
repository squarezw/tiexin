class AddScoreFieldsToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :quality_score, :float, :default => 0
    add_column :hot_spots, :service_score, :float, :default => 0
    add_column :hot_spots, :environment_score, :float, :default => 0
    add_column :hot_spots, :price_score, :float, :default => 0
    add_column :hot_spots, :score, :float, :default => 0
  end

  def self.down
    remove_column :hot_spots, :quality_score
    remove_column :hot_spots, :service_score
    remove_column :hot_spots, :environment_score
    remove_column :hot_spots, :price_score
    remove_column :hot_spots, :score
  end
end
