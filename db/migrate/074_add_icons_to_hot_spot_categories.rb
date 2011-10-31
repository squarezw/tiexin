class AddIconsToHotSpotCategories < ActiveRecord::Migration
  def self.up
    add_column :hot_spot_categories, :map_icon, :string
    add_column :hot_spot_categories, :big_icon, :string
  end

  def self.down
    remove_column :hot_spot_categories, :map_icon
    remove_column :hot_spot_categories, :big_icon
  end
end
