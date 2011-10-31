class AddHasMapToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :has_map, :boolean,  :default => true
  end

  def self.down
    remove_column :cities, :has_map
  end
end
