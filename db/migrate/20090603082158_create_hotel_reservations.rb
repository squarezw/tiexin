class CreateHotelReservations < ActiveRecord::Migration
  def self.up
    create_table :hotel_reservations, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :hotel_id, :null=>false
      t.integer :member_id
      t.date :start_date
      t.integer :days
      t.string :contact,  :limit=>100
      t.string :phone_number,  :limit=>100
      t.string :memo,  :limit=>3000
      t.timestamps
    end
  end

  def self.down
    drop_table :hotel_reservations
  end
end
