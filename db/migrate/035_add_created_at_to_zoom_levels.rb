class AddCreatedAtToZoomLevels < ActiveRecord::Migration
  def self.up
    add_column :zoom_levels, :created_at, :datetime
  end

  def self.down
    remove_column :zoom_levels, :created_at
  end
end
