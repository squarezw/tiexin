class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :hot_spots, :created_at
    add_index :access_logs, :created_at
    add_index :hot_spot_tags, :tag
  end

  def self.down
    remove_index :hot_spots, :created_at
    remove_index :hot_spots, :column=>[:x, :y]
    remove_index :access_logs, :created_at
  end
end
