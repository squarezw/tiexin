xml.result(:code => 100 ) do
  xml.result_number :number=>@hot_spots.total_entries
  @hot_spots.each do |hot_spot|
    xml.hot_spot(:id => hot_spot.id, :name => localized_description(hot_spot, :name), :category_id =>hot_spot.hot_spot_category_id ) do 
      xml.address(localized_description(hot_spot, :address))
      xml.introduction(localized_description(hot_spot, :introduction))
      if (positions = @container_hot_spot.positions_for_inner_hot_spot hot_spot) and !positions.empty?
        pos = positions[0]
        xml.position :layout_map_id => pos.layout_map_id, :x=>pos.x, :y=>pos.y 
      end
    end
  end
end