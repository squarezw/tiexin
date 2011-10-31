class AddBrandIdToBrands < ActiveRecord::Migration
  def self.up
    add_column :hot_spots ,:brand_id, :integer
  end

  def self.down
    remove_column :hot_spots ,:brand_id
  end
end
