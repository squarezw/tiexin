require 'imon_exception'
require 'find_hot_spot'
require 'dynamic_query'

class InnerHotSpotsController < HotSpotsController     
  include FindHotSpot
  include Imon::DynamicQuery
  helper 'hot_spots'    
  helper 'photos'
  
  before_filter :find_container_hot_spot, 
                :except=>[:auto_complete_for_brand_name_zh_cn,
                          :auto_complete_for_brand_name_zh_en]
  
  auto_complete_for :brand, :name_zh_cn, :limit => 10
  auto_complete_for :brand, :name_en, :limit=>10
  
  def index
    if params[:order_by]
      order_by = params[:order_by]
    else
      order_by = "name_#{@current_lang}"
    end    
    
    if @mobile_user
      spec = build_spec_for_search
      parse_start_limit 
      @hot_spots = HotSpot.search @current_city, spec, :page=>(@start) / @limit+1, :per_page=>@limit
      logger.info "@hot_spots.class = #{@hot_spots.class}"
    else
      @hot_spots = HotSpot.paginate_by_city_id_and_container_id  @container_hot_spot.city_id, 
                              @container_hot_spot.id,
                              :order => order_by,
                              :per_page => 20,
                              :page=>params[:page]
    end

    respond_to do |format|
      format.html {
        if request.xhr?
          render :layout=>false
        else
          render :action=>'index_full', :layout=>'default'
        end
      }
      format.xml {render :layout=>false}
    end
  end
  
  def search
    spec = build_spec_for_search
    
    if params[:order_by]
      order_by = params[:order_by]
    else
      order_by = "name_#{@current_lang}"
    end    
    
    @hot_spots = HotSpot.search @container_hot_spot.city, spec, 
                  :order=>order_by, :per_page=>20, :page=>params[:page]
  end
  
  def show                             
    @container_hot_spot = HotSpot.find(params[:hot_spot_id])
    @hot_spot = HotSpot.find(params[:id])
    render :layout=>false
  end

  def new
    
  end           
  
  def create
     @hot_spot = create_hot_spot(params)
     @container_hot_spot.hot_spots << @hot_spot
     @hot_spot.x = @container_hot_spot.x
     @hot_spot.y = @container_hot_spot.y
     begin    
      HotSpot.transaction do 
        if @hot_spot.save    
          if params[:position]
            @position = @hot_spot.positions.create(params[:position])
            raise ActiveRecord::ActiveRecordError unless @position.errors.blank?
          end
        else
          raise ActiveRecord::ActiveRecordError
        end
      end
      unless @position     
        render :update do |page|
          page.call "show_inner_hot_spots"
        end
      end
    rescue ActiveRecord::ActiveRecordError
      render :update do |page|
        messages = @hot_spot.errors.full_messages
        messages = messages.concat(@position.errors.full_messages) if @position
        page.replace_html 'form_error', messages.join('<br/>')
        page.call 'dialog.show'
      end
    end
  end         
  
  def search_for_add
    if params[:layout_map_id]
      search_for_add_to_layout_map
      render :template => 'inner_hot_spots/search_for_add_to_layout_map' 
    else
      if params[:keyword]
        keyword = "%#{params[:keyword]}%"
        @hot_spots = HotSpot.paginate :conditions => ['city_id = ? and id <> ? and container_id is null and (name_zh_cn like ? or name_en like ?)', @current_city.id, @container_hot_spot.id, keyword, keyword],
                              :order => "name_#{@current_lang}", 
                              :per_page => 6,
                              :page=>params[:page]
      else
        @hot_spots = HotSpot.paginate :conditions => ['city_id = ? and container_id is null and id <> ?', @current_city.id, @container_hot_spot.id],
                              :order => "name_#{@current_lang}", 
                              :per_page => 6,
                              :page => params[:page] 
      end
    end
  end
  
  def add
    @hot_spot = HotSpot.find(params[:id])
    HotSpot.transaction do 
      unless @hot_spot.coordinate
        @hot_spot.update_attributes! :x => @container_hot_spot.x, :y => @container_hot_spot.y 
      end
      @container_hot_spot.hot_spots << @hot_spot
    end 
  end
  
  def destroy
    @hot_spot = @container_hot_spot.hot_spots.find params[:id]
    @hot_spot.update_attribute_with_validation_skipping(:container, nil)
    @container_hot_spot.layout_maps.each  { |map| map.hot_spots.delete @hot_spot }
  end
  
  private
  def search_for_add_to_layout_map
    if params[:keyword]
      keyword = "%#{params[:keyword]}%"
      @hot_spots = HotSpot.paginate :conditions => [%q/city_id = ? and id <> ? and (name_zh_cn like ? or name_en like ?) and (not exists (select * from positions p, layout_maps l where l.layoutable_type='HotSpot' and l.layoutable_id = ? and p.layout_map_id = l.id and p.hot_spot_id = hot_spots.id))/, @current_city.id, @container_hot_spot.id, keyword, keyword, @container_hot_spot.id],
               :order => "name_#{@current_lang}",
               :per_page => 6,
               :page=>params[:page]
    else
      @hot_spots = HotSpot.paginate :conditions=>["container_id =? and id <> ? and (not exists (select * from positions p, layout_maps l where l.layoutable_type='HotSpot' and l.layoutable_id = ? and p.layout_map_id = l.id and p.hot_spot_id = hot_spots.id))", @container_hot_spot.id, @container_hot_spot.id, @container_hot_spot.id],
                                  :order=>"name_#{@current_lang}",
                                  :per_page=>6,
                                  :page=>params[:page]
                                  
    end  
  end
  
  def build_spec_for_search
    spec = {:container=>@container_hot_spot, :name=>params[:keyword]}

    if params[:category_id] and !params[:category_id].empty?
      spec[:hot_spot_category] = HotSpotCategory.find params[:category_id]
    elsif params[:hot_spot_category_id] and !params[:hot_spot_category_id].empty?
      spec[:hot_spot_category] = HotSpotCategory.find params[:hot_spot_category_id]      
    end
    
    spec[:layout_map] = params[:layout_map_id] unless params[:layout_map_id].nil? or params[:layout_map_id].empty?
    return spec
  end
  
end
