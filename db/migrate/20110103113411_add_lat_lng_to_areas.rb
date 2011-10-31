class AddLatLngToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :latitude, :decimal, :precision=>18, :scale=>15
    add_column :areas, :longitude, :decimal, :precision=>18, :scale=>15
  end

  def self.down
    remove_column :areas, :latitude
    remove_column :areas, :longitude
  end
end
