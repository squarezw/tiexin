xml.result :code=>100 do 
  @hot_spots.each { |hot_spot| 
    xml.hot_spot :id=>hot_spot.id, :name=>localized_description(hot_spot, :name), :city_id=>hot_spot.city_id, :category_id=>hot_spot.hot_spot_category.id, :x=>hot_spot.x, :y=>hot_spot.y, :address=>localized_description(hot_spot, :address)
  }
end