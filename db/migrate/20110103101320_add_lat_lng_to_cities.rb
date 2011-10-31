class AddLatLngToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :latitude, :decimal, :precision=>18, :scale=>15
    add_column :cities, :longitude, :decimal, :precision=>18, :scale=>15
  end

  def self.down
    remove_column :cities, :latitude
    remove_column :cities, :longitude    
  end
end
