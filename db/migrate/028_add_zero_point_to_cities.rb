class AddZeroPointToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :x0, :decimal, :precision=>12, :scale=>2
    add_column :cities, :y0, :decimal, :precision=>12, :scale=>2
    City.reset_column_information
    city = City.find(1)
    city.update_attributes(:x0 => 12728253.98, :y0 => 5110764.45 )
  end

  def self.down
    remove_column :cities, :x0
    remove_column :cities, :y0
  end
end
