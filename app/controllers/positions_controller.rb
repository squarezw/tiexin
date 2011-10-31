require 'dynamic_query'
class PositionsController < ApplicationController     
  include Imon::DynamicQuery
  
  before_filter :is_admin, :only => [:move] 
  before_filter :find_layout_map
  helper 'hot_spots'
  helper 'inner_hot_spots'
  helper 'hot_spot_categories'
    
  def index
    respond_to do |format|
      format.js {
      }
      format.xml {
        @category_ids = (@layout_map.hot_spots.collect {|hot_spot| hot_spot.hot_spot_category_id}).uniq
      }
    end
  end  
  
  def create
    @layoutable = @layout_map.layoutable
    @hot_spot = HotSpot.find params[:position]['hot_spot_id']
    @new_inner_hot_spot = ! @layoutable.hot_spots.include?(@hot_spot)
    if Position.exists_for?(params[:position]['hot_spot_id'], @layout_map)
      alert _('This hot spot has already been in this layout map.')
      return
    end
    #TODO: Transaction ! Update @hot_spot's x and y.
    HotSpot.transaction do 
      @position = @layout_map.positions.create(params[:position])
      @layoutable.hot_spots << @hot_spot
    end 
  end
  
  def move
    @position = @layout_map.positions.find(params[:id])
    @position.update_attributes :x => params[:x], :y => params[:y]           
    render :update do |page|
      page << "xnavi_map.move_marker_to(#{@position.id}, #{@position.x}, #{@position.y});"
    end 
  end

  def find_layout_map
    @layout_map = LayoutMap.find(params[:layout_map_id])
  end
end
