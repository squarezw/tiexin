xml.result :code=>'100' do 
  if @start== 0
    xml.result_number :number=>@hot_spots.total_entries
  end
  @hot_spots.each do |hot_spot|
    xml.hot_spot :id=>hot_spot.id, 
                 :category_id=>hot_spot.hot_spot_category_id, 
                 :hot_spot_category_name=>localized_description(hot_spot.hot_spot_category, :name),
                 :name=>localized_description(hot_spot, :name), 
                 :address=>localized_description(hot_spot, :address), 
                 :x=>hot_spot.x, 
                 :y=>hot_spot.y do 
      xml.phone_number hot_spot.phone_number
    end
  end
end