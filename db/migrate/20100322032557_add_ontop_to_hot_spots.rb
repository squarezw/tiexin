class AddOntopToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :ontop, :boolean
  end

  def self.down
    remove_column :hot_spots, :ontop
  end
end
