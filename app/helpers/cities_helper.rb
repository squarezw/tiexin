module CitiesHelper
  def start_point
    if @hot_spots and !@hot_spots.empty?
      hot_spot = @hot_spots.detect { |hs| hs.coordinate }
      "[#{hot_spot.coordinate.x}, #{hot_spot.coordinate.y}]"      
    elsif @area
      "[#{@area.center.x}, #{@area.center.y}]"
    else
      "[#{@current_city.start_point.x}, #{@current_city.start_point.y}]"
    end
  end

  def start_point_for_gmap
    if @hot_spots and !@hot_spots.empty?
      hot_spot = @hot_spots.first
      "#{hot_spot.latitude}, #{hot_spot.longitude}"
    elsif @area
      "#{@area.center.x}, #{@area.center.y}"
    else
      "#{@current_city.latitude}, #{@current_city.longitude}"
    end
  end
  
  def show_all_link(count)
    _('All %{c} results......') % { :c => count }
  end
  
  def show_area_markers(page, areas)
    areas.each do |area|
      add_area_marker page, area
    end
  end
  
  def show_hot_spot_markers(page, hot_spots)
    hot_spots.each do |hot_spot|
      add_hot_spot_marker page, hot_spot
    end
  end
  
  def link_to_channel_of_category(cat)
    channel = Channel.find_by_hot_spot_category_id cat.id
    path = channel ? city_channel_path(@current_city, channel) : city_hot_spot_category_path(@current_city, cat)
    link_to image_tag('more.jpg'), path
  end
  
  def xnavi_recommends(city, count=4)
    return city.random_contract_hot_spots(count)
  end
  
  def funtion_to_show_calendar_at_date(date)
    "show_calendar_at_date('#{date.to_formatted_s(:db)}')"
  end
end
