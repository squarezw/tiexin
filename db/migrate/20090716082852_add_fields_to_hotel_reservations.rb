class AddFieldsToHotelReservations < ActiveRecord::Migration
  def self.up
    add_column :hotel_reservations, :tenant, :string,  :limit=>100
    add_column :hotel_reservations, :mobile_number, :string,  :limit=>20
    add_column :hotel_reservations, :end_date, :date
  end

  def self.down
    remove_column :hotel_reservations, :tenant
    remove_column :hotel_reservations, :mobile_number
    remove_column :hotel_reservations, :end_date
  end
end
