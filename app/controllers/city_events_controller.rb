class CityEventsController < ApplicationController
  before_filter :find_city
  layout 'default', :only=>:index
  
  helper 'hot_spots'
  
  def index
    @events = Event.effective_for_city(@current_city, {}, {:page=>params[:page]})
    @hot_spot_event_map = []
    @start_point = @current_city.start_point
    @date = Date.today
    unless @events.empty?
      @hot_spot_event_map = build_hot_spot_event_map
      e = @events.find { |event| event.vendor.is_a? HotSpot}
      @start_point = e.vendor.coordinate unless e.nil?
    end
    if request.xhr?
      render :action=>'for_date', :layout=>false    
    else
      @tags = Event.tags @current_city
      find_data_ranges :date=>@date
    end
  end
  
  def tags
    conditions = {}
    conditions[:event_category_id] = params[:event_category_id] unless params[:event_category_id].nil? or params[:event_category_id].empty?
    conditions[:month] = Date.parse params[:month] unless params[:month].nil? or params[:month].empty?
    @tags = Event.tags @current_city, conditions
  end
  
  def for_date
    @date = Date.parse params[:date]
    conditions = {:date=>@date}
    conditions[:event_category_id] = params[:event_category_id] unless params[:event_category_id].nil? or params[:event_category_id].empty?
    conditions[:tag_id] = params[:tag_id] if params[:tag_id]
    conditions[:tag_id] = params[:tag_id] if params[:tag_id]
    @events = Event.effective_for_city(@current_city, conditions, {:page=>params[:page]})
    @hot_spot_event_map = build_hot_spot_event_map
  end
  
  def for_month
    @date = Date.today
    @date = Date.parse params[:date] unless params[:date].nil? or params[:date].empty?
    conditions = {:month=>@date}
    conditions[:event_category_id] = params[:event_category_id] unless params[:event_category_id].nil? or params[:event_category_id].empty?
    conditions[:tag_id] = params[:tag_id] if params[:tag_id]
    @events = Event.effective_for_city(@current_city, conditions, {:page=>params[:page]})
    @hot_spot_event_map = build_hot_spot_event_map    
    find_data_ranges conditions
  end
  
  private
  def find_city
    adjust_current_city City.find(params[:city_id])
  end

  def build_hot_spot_event_map
    @events.inject({}) do |map, event|
      if event.vendor.is_a? HotSpot
        if map.has_key? event.vendor
          map[event.vendor] << event
        else
          map[event.vendor] = [event]
        end
      end
      map
    end
  end

  def find_data_ranges(conditions={})
    @date_ranges = Event.date_ranges(@current_city, conditions)
  end
end
