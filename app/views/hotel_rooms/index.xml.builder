xml.result :code=>100 do 
  @hotel_rooms.each do |hotel_room|
  xml.hotel_room :id=>hotel_room.id, :name=>hotel_room.name,  :bed => hotel_room.bed, :price => hotel_room.price, :discount_price => hotel_room.discount_price, :breakfast => format_boolean_for_xml(hotel_room.breakfast), :network => format_boolean_for_xml(hotel_room.network), 
    :pic => hotel_room.pic?? hotel_room.pic.mobile.url : ""
  end
end