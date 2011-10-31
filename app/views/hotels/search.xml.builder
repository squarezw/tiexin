xml.result :code=>100 do 
  if @start == 0
    xml.result_number :number=>@hotels.total_entries
  end
  @hotels.each do |hotel|
    if @current_city.has_map
      xml.hotel(:id=>hotel.id, :name=>hotel.hotel_name, :city_id=>hotel.city_id, :category_id=>hotel.hotel_category_id, :x=>hotel.x, :y=>hotel.y, :address=>hotel.hotel_address, :score => hotel.score, :score_count => hotel.score_count , :photo => (hotel.hot_spot.photos.empty?? "": hotel.hot_spot.photos.first.photo.mobile.url) ) do
          @hotel_rooms = hotel.hotel_rooms_of_price(params[:price_min],params[:price_max])
          @hotel_rooms.each do |hotel_room|  
              xml.hotel_room :id => hotel_room.id, :name => hotel_room.name, :pic => hotel_room.pic,  :bed => hotel_room.bed , :price => hotel_room.price, :discount_price => hotel_room.discount_price, :breakfast => format_boolean_for_xml(hotel_room.breakfast), :network => hotel_room.network, 
              :pic => hotel_room.pic?? hotel_room.pic.mobile.url : ""
          end
        end
    else
      xml.hotel(:id=>hotel.id, :name=>hotel.hotel_name, :city_id=>hotel.city_id, :category_id=>hotel.hotel_category_id, :address=>hotel.hotel_address, :score=>0, :score_count => 0, :map_1 =>safe_map_url(hotel,1), :map_2 => safe_map_url(hotel,2), :map_3 => safe_map_url(hotel,3), :photo => hotel.photo.url) do
          @hotel_rooms = hotel.hotel_rooms_of_price(params[:price_min],params[:price_max])
          @hotel_rooms.each do |hotel_room|  
            xml.hotel_room :id => hotel_room.id, :name => hotel_room.name, :pic => hotel_room.pic,  :bed => hotel_room.bed , :price => hotel_room.price, :discount_price => hotel_room.discount_price , :breakfast => format_boolean_for_xml(hotel_room.breakfast), :network => hotel_room.network, 
              :pic => hotel_room.pic?? hotel_room.pic.mobile.url : ""
          end
        end
    end
  end
end