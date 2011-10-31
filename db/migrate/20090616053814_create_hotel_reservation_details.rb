class CreateHotelReservationDetails < ActiveRecord::Migration
  def self.up
    create_table :hotel_reservation_details, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :hotel_reservation_id, :null => false
      t.integer :hotel_room_id, :null => false
      t.integer :number
      t.float :price
      t.timestamps
    end
  end

  def self.down
    drop_table :hotel_reservation_details
  end
end
