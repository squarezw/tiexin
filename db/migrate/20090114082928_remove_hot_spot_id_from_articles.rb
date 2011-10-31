class RemoveHotSpotIdFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :hot_spot_id
  end

  def self.down
    add_column :articles, :hot_spot_id, :integer
  end
end
