xml.result(:code => 100) do
  @layout_maps.each do |map|
    url = map.zoom_levels.first.map_file.large.url
    xml.layout_map(:id => map.id, :name => localized_description(map, :name), :hot_spot_count=>map.hot_spots.size ) do 
      
      xml.introduction(localized_description(map, :introduction))
      
      map.zoom_levels.each do |zoom_level|
        xml.zoom_level :id => zoom_level.id, :width => zoom_level.map_file_width, :height=>zoom_level.map_file_height, :scale => zoom_level.scale   
      end
      
      map.hot_spot_category_ids.each do |id|
        xml.hot_spot_category :id=>id
      end
    end
  end
end