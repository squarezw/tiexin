class CreateHotelRooms < ActiveRecord::Migration
  def self.up
    create_table :hotel_rooms,  :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :hotel_id, :null=>false
      t.string :name, :limit=>1000, :null=>false
      t.float :price,  :null=>false
      t.string :bed, :limit=>1000
      t.boolean :breakfast
      t.boolean :network      
      t.string :pic
      t.string :memo, :limit=>3000
      t.timestamps
    end
  end

  def self.down
    drop_table :hotel_rooms
  end
end
