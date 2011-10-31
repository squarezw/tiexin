class HotelReservation < ActiveRecord::Base
  validates_presence_of :phone_number, :start_date, :end_date
  
  has_many :hotel_reservation_details, :dependent=>:delete_all
  belongs_to :hotel
  belongs_to :member
  
  def before_save
      self.days = (self.start_date..self.end_date).to_a.size
  end
end
