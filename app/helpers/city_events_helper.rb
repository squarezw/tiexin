module CityEventsHelper
  def show_calendar
    render :partial=>'/calendar', 
           :locals=>{:date=>@date, 
                     :day_renderer=>proc { |day| render_day (day) }
                    }
  end
  
  def has_event_on(date)
    @date_ranges.find { |range| (range[0]..range[1]).include? date }
  end
  
  def render_day(day)
    if day.month == @date.month and has_event_on(day)
      link_to_function day.day, "show_date('#{day.to_formatted_s(:db)}')"
    else
      day.day
    end
  end
  
  def add_events_to_map(map)
    update_page do |page|
      map.each_pair { |hot_spot, events| 
        add_hot_spot_marker page, hot_spot, :bubble_content=>render(:partial=>'hot_spot', :locals=>{:events=>events}, :object=>hot_spot)
  		}
	  end
  end
  
  def add_hot_spot_to_map_with_events(page, hot_spot, events)
    add_hot_spot_marker page, hot_spot, :bubble_content=>render(:partial=>'hot_spot', :locals=>{:events=>events}, :object=>hot_spot)    
  end
end
