xml.result(:code => 100) do
  xml.traffic_line(:id => @traffic_line.id, 
                   :name => h(localized_description(@traffic_line, :name)),
                   :type => @traffic_line.line_type) do
     xml.operation_time h(localized_description(@traffic_line.operation_time))
     @traffic_line.traffic_stops.each do |stop|
        hot_spot = stop.hot_spot
        xml.stop(:hot_spot_id => hot_spot.id, :name => localized_description(hot_spot, :name), :x => hot_spot.x, :y=>hot_spot.y) 
     end
  end
end