require 'dynamic_query'
require 'coordinate'

class NearbyHotSpotsController < ApplicationController
  include Imon::DynamicQuery
  helper 'hot_spot_categories'
  helper 'hot_spots'
  
  def index
     do_search
  end

  def create
    do_search
  end
  
  def show
    do_search          
  end

  private 
  def caculate_scope
    if params[:scope]
      scope = params[:scope].to_f
    else
      scope = 0.2
    end
    return [[2, scope].min, 0.2].max
  end

  def do_search
    @hot_spot = HotSpot.find(params[:hot_spot_id])
    if params[:order_by]
      order_by = params[:order_by]
      order_by = "distance(hot_spots.x, hot_spots.y, #{@hot_spot.x}, #{@hot_spot.y})" if order_by == 'distance'
    else
      order_by = 'x, y'
    end
    spec= {:hot_spot_category=>params[:category_id], 
           :nearby=>{:scope=>caculate_scope, :x=>@hot_spot.x, :y=>@hot_spot.y},
           :exclude=>@hot_spot.id}
    @hot_spots = HotSpot.search @hot_spot.city, 
                                spec, 
                                :order => order_by,
                                :per_page => 20,
                                :page=>params[:page]
  end
end
