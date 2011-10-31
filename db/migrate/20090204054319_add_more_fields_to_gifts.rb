class AddMoreFieldsToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :reference_price, :float
    add_column :gifts, :reference_url, :string, :limit=>300
    add_column :gifts, :support_deliver_method, :string
  end

  def self.down
    remove_column :gifts, :reference_price
    remove_column :gifts, :reference_url
    remove_column :gifts, :support_deliver_method
  end
end
