class AddDiscountPriceToHotelRooms < ActiveRecord::Migration
  def self.up
    add_column :hotel_rooms, :discount_price, :integer
  end

  def self.down
    remove_column :hotel_rooms, :discount_price
  end
end
