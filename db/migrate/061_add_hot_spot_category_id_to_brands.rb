class AddHotSpotCategoryIdToBrands < ActiveRecord::Migration
  def self.up
    add_column :brands, :hot_spot_category_id, :integer
  end

  def self.down
    remove_column :brands, :hot_spot_category_id
  end
end
