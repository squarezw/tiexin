class AddLatLngToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :latitude, :decimal, :precision=>18, :scale=>15
    add_column :hot_spots, :longitude, :decimal, :precision=>18, :scale=>15
  end

  def self.down
    remove_column :hot_spots, :latitude
    remove_column :hot_spots, :longitude
  end
end
