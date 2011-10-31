xml.result :code=>100 do
   xml.hotel_reservation :id => @hotel_r.id, :hotel_name => @hotel_r.hotel.hotel_name, :contact => @hotel_r.contact, :phone_number => @hotel_r.phone_number do
      if @hotel_r.hotel_reservation_details
        @hotel_r.hotel_reservation_details.each do |hotel_r_d|
            xml.hotel_room :hotel_room_name => hotel_r_d.hotel_room.name,  :price => hotel_r_d.price, :number => hotel_r_d.number
        end
      end
      xml.memo @hotel_r.memo
   end
end
