xml.result :code=>100 do
  @hotel_rs.each do |hotel_r|
    xml.hotel_reservation :id => hotel_r.id, :hotel_name => hotel_r.hotel.hotel_name, :created_at => format_time_for_xml(hotel_r.created_at)
  end
end
