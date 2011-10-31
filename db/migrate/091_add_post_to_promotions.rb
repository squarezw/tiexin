class AddPostToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :post, :string, :limit => 500
  end

  def self.down
    remove_column :promotions, :post
  end
end
