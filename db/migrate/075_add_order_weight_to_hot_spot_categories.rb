class AddOrderWeightToHotSpotCategories < ActiveRecord::Migration
  def self.up
     add_column :hot_spot_categories, :order_weight, :integer, :default => 0
  end

  def self.down
    remove_column :hot_spot_categories, :order_weight
  end
end
