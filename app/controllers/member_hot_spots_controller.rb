class MemberHotSpotsController < ApplicationController
  layout 'default'
  
  def index

    if @mobile_user
      parse_start_limit
      page = (@start / @limit) + 1
      per_page = @limit
      logger.info "start, limit, page = #{@start}, #{@limit}, #{page}"
    else
      page = params[:page]
      if request.xhr?
        per_page = 5
      else
        per_page = 20
      end
    end

    @member = Member.find(params[:member_id])

    spec = {}
    if params[:keyword]
      spec[:name] = params[:keyword]
    else
      if params[:member_id]
        spec[:creator] = params[:member_id]
      end
    end
    
    spec[:city] = params[:city_id] if params[:city_id]
    @hot_spots = HotSpot.search2 spec, {:order=>'created_at', :page=>page, :per_page=>per_page}

     if request.xhr?
       render :partial=>'search', :layout=>false
     else
       respond_to do |format|
         format.html
         format.xml {render :layout=>false}
       end
     end
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
