class AddOwnerToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :owner_id, :integer
  end

  def self.down
    remove_column :hot_spots, :owner_id
  end
end
