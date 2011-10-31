module MainHelper    
  def show_all_link(count)
    _('All %{c} results......') % { :c => count }
  end
  
  def show_hot_spot_markers(page, hot_spots)
    hot_spots.each do |hot_spot|
      if ! hot_spot.container
        add_hot_spot_marker page, hot_spot 
      elsif hot_spot.container.x
        add_hot_spot_marker page, hot_spot.container
      end
    end
  end
  
  def show_area_markers(page, areas)
    areas.each do |area|
      add_area_marker page, area
    end
  end
  
  def start_point
    if @hot_spot and @hot_spot.coordinate
      "[#{@hot_spot.coordinate.x}, #{@hot_spot.coordinate.y}]"
    elsif @area
      "[#{@area.center.x}, #{@area.center.y}]"
    else
      "[#{@current_city.start_point.x}, #{@current_city.start_point.y}]"
    end
  end
  

end
