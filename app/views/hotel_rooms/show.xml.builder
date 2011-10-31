xml.result :code=>100 do 
  xml.hotel :id=>@hotel_room.hotel.id, :name=>@hotel_room.hotel.hotel_name,  :category_id => @hotel_room.hotel.category_id, :address => @hotel_room.hotel.address do 
    xml.hotel_room :id => @hotel_room.id, :name => @hotel_room.name,  :pic => @hotel_room.pic?? @hotel_room.pic.mobile.url : "", :bed => @hotel_room.bed, :price => @hotel_room.price, :discount_price => @hotel_room.discount_price,:breakfast => @hotel_room.breakfast, :network => @hotel_room.network do
      xml.memo @hotel_room.memo
    end
 end  
end