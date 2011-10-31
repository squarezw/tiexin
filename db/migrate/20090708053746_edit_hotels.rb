class EditHotels < ActiveRecord::Migration
  def self.up
    add_column :hotels, :photo, :string
    add_column :hotels, :name, :string
    add_column :hotels, :category_id, :integer
    add_column :hotels, :address, :string, :limit => 500
    add_column :hotels, :map_1, :string
    add_column :hotels, :map_2, :string
    add_column :hotels, :map_3, :string
    add_column :hotels, :city_id, :integer
    add_column :hotels, :district_id, :integer
    change_column :hotels, :hot_spot_id, :integer,  :null => true
  end

  def self.down
    remove_column :hotels, :photo
    remove_column :hotels, :name
    remove_column :hotels, :category_id
    remove_column :hotels, :address
    remove_column :hotels, :map_1
    remove_column :hotels, :map_2
    remove_column :hotels, :map_3
    remove_column :hotels, :city_id
    remove_column :hotels, :district_id
    change_column :hotels, :hot_spot_id, :integer, :null => false
  end
end
