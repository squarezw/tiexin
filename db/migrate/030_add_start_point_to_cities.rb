class AddStartPointToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :start_point_x, :integer
    add_column :cities, :start_point_y, :integer
    City.reset_column_information
    city = City.find(1)
    city.update_attributes!(:start_point_x => 22836224, 
                            :start_point_y => 28611179 )
  end

  def self.down
    remove_column :cities, :start_point_x
    remove_column :cities, :start_point_y
  end
end
