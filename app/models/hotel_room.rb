class HotelRoom < ActiveRecord::Base
    has_many :hotel_reservation_details, :dependent=>:delete_all
    belongs_to :hotel
    
    image_column :pic, :validate_integrity=>false, :versions=> {:mobile=>'120x80'}
    
    validates_presence_of :name, :price, :discount_price
end
