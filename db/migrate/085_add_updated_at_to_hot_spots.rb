class AddUpdatedAtToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :updated_at, :datetime
    execute 'update hot_spots set updated_at = created_at'
  end

  def self.down
    remove_column :hot_spots, :updated_at
  end
end
