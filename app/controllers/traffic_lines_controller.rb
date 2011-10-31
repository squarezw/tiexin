class TrafficLinesController < ApplicationController
  helper 'hot_spots'
  
  def index
    @hot_spot = HotSpot.find params[:hot_spot_id]
    @traffic_lines = @hot_spot.traffic_lines
    respond_to do |format|
      format.xml
    end
  end
  
  def show
    @traffic_line = TrafficLine.find(params[:id])
    @near_hot_spot = HotSpot.find params[:near_hot_spot_id] if params[:near_hot_spot_id]
    adjust_current_city @traffic_line.city
    respond_to do |format|
      format.xml { render :template => 'traffic_lines/show', :layout => false  }
      format.html
    end
  end
end
