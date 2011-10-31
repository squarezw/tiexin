xml.result(:code=>'100') do
  xml.cities do
    @cities.each do |city|
      if city.has_map
        xml.city(:id => city.id, :name => localized_description(city, :name), :has_map => city.has_map ) do
          xml.width city.width
          xml.height city.height
          xml.start_map_level 6
          xml.start_point :x => city.start_point_x, :y => city.start_point_y  
          city.map_levels_for_mobile.each do |level|
            xml.map_level(:no => level.no, :row => level.row, :column=>level.column )
          end
        end        
      else
        xml.city(:id => city.id, :name => localized_description(city, :name), :has_map => city.has_map)
      end      
    end
  end
end