class AddCommonToHotSpotCategories < ActiveRecord::Migration
  def self.up
    add_column :hot_spot_categories, :common, :boolean, :default=>false
    execute 'update hot_spot_categories set common = 0'
  end

  def self.down
    drop_column :hot_spot_categories, :common
  end
end
