class Admin::TrafficStopsController < ApplicationController
  before_filter :is_admin
  before_filter :find_traffic_line
  
  def create
    @hot_spot = HotSpot.find params[:hot_spot_id]
    if @traffic_line.traffic_stop_ids.include? @hot_spot.id
      alert _('The traffic line has already contains this stop.')
    else
      @stop = @traffic_line.traffic_stops.create(:hot_spot=>@hot_spot)
      @stop.save    
    end
  end
  
  def sort
    @traffic_line.traffic_stops.each do |stop|
      stop.position = params[:lst_traffic_stops].index(stop.id.to_s)
      stop.save
    end
    render  :nothing=>true
  end
  
  def destroy
    @traffic_stop = @traffic_line.traffic_stops.find params[:id]
    @traffic_stop.destroy
  end
  
  def find_traffic_line
    @traffic_line = TrafficLine.find(params[:traffic_line_id])
  end
end
