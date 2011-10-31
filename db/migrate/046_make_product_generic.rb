class MakeProductGeneric < ActiveRecord::Migration
  def self.up
    add_column :products, :vendor_type, :string, :limit => 20, :null => true 
    rename_column :products, :hot_spot_id, :vendor_id
    execute %/update products set vendor_type = 'HotSpot'/
  end

  def self.down
    rename_column :products, :vendor_id, :hot_spot_id
    remove_column :products, :vendor_type
  end
end
