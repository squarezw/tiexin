class AddKeywordToCategory < ActiveRecord::Migration
  def self.up
    add_column :hot_spot_categories, :keyword, :string, :limit=>300
  end

  def self.down
    remove_column :hot_spot_categories, :keyword
  end
end
