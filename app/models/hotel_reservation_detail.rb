class HotelReservationDetail < ActiveRecord::Base
  belongs_to :hotel_room
  belongs_to :hotel_reservation
  
  validates_presence_of :number
  
end
