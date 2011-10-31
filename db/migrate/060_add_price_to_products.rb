class AddPriceToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :price, :string, :limit=>100
  end

  def self.down
    remove_column :products, :price
  end
end