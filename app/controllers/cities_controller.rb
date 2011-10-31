require 'dynamic_query'
  
class CitiesController < ApplicationController
  include Imon::DynamicQuery

  before_filter :find_city, :except => [:index] 
  layout 'default', :except=>[:bind, :auto_complete_for_area]
  
  helper 'hot_spots'
  helper 'hot_spot_categories'
  helper 'layout_maps'
  helper 'areas'
  helper 'promotions'
  helper 'events'
  
  def index
    respond_to do |format|
      format.html {
        if @current_city.topics
          @topic = @current_city.topics.first    
        end
        @comments = Comment.find :all, :conditions=>['commentable_type=? and exists (select * from hot_spots where hot_spots.id = comments.commentable_id and hot_spots.city_id = ?)', 'HotSpot', @current_city.id], :order=>'created_at desc', :limit=>5
        render :action => 'show', :layout=>'homepage'
      }
      format.xml { 
        if params.has_key? :last_download_at
          last_download_at = Time.parse params[:last_download_at]
          logger.info "last_download_at = #{last_download_at}"
          a=City.connection.select_one 'select max(created_at), max(updated_at) from cities'
          if last_download_at >= Time.parse(a.values.max)
            error_xml 101
            return
          end
        end
        # 2010-3-8日,临时增加的接口参数,用于判断是否调用有无地图城市列表
        if params[:has_map] and params[:has_map] == "all"
          conditions = []
        else
          conditions = ["has_map = ?",true]
        end
        @cities = City.find(:all, :conditions => conditions,:order => "name_#{@current_lang}" )
        render :layout=>false
      }
      format.xhtmlmp {
        render :action=>'show', :layout=>'wap'
      }
    end 
  end
  
  def show
    if @current_city.topics
      @topic = @current_city.topics.first    
    end
    @comments = Comment.find :all, :conditions=>['commentable_type=? and exists (select * from hot_spots where hot_spots.id = comments.commentable_id and hot_spots.city_id = ?)', 'HotSpot', @current_city.id], :order=>'created_at desc', :limit=>5
    respond_to do |format|
      format.html { render :layout=>'homepage' }
      format.xhtmlmp { render :layout=>'wap' }
    end
  end
  
  def bind
    respond_to do |format|
      format.html {
        redirect_to main_path        
      }
      format.xml {
        @current_user.city_for_mobile = @city
        @current_user.save
      }
    end
  end
  
  def map
    @hide_search_result = true
    if params.has_key?(:hot_spot_id)
      hot_spot = @current_city.hot_spots.find params[:hot_spot_id] 
      @hot_spots = [hot_spot]
      @hot_spots_count = 1
    end
    if params.has_key?(:area_id)
      area = Area.find(params[:area_id]) 
      @areas = [area]
      @areas_count = 1
    end
  end

  def gmap
    @hide_search_result = true
    if params.has_key?(:hot_spot_id)
      hot_spot = @current_city.hot_spots.find params[:hot_spot_id]
      @hot_spots = [hot_spot]
      @hot_spots_count = 1
    end
    if params.has_key?(:area_id)
      area = Area.find(params[:area_id])
      @areas = [area]
      @areas_count = 1
    end
  end
  
  def auto_complete_for_area
    area = params[:area]
    if area.is_a? Hash
      keyword = area[:name]
    elsif area.is_a? Array
      keyword = area[0]
    else
      keyword = area.to_s
    end
    kw = City.connection.quote "%#{keyword}%"
#    @areas = @current_city.areas.find :all,
#                                      :conditions=>['name_zh_cn like ? or name_en like ?', kw, kw],
#                                      :order=>"name_#{current_lang}",
#                                      :limit=>10
     sql = <<SQL
 select distinct name from (
 	((select distinct name_zh_cn name from areas where city_id = #{@current_city.id} and name_zh_cn like #{kw} order by char_length(name_zh_cn) limit 20)
 	 union
 	 (select distinct name_zh_cn name from roads where city_id = #{@current_city.id} and name_zh_cn like #{kw} order by char_length(name_zh_cn) limit 20)
 	) a
 )
 order by char_length(name) limit 20;
SQL
     @rows = City.connection.select_values sql
  end
  
  def event_calendar
    @date = Date.parse(params[:date])
    render :layout=>false
  end
  
  private
  def find_city
    begin
      city = City.find params[:id]    
      adjust_current_city city
    rescue ActiveRecord::RecordNotFound => ex
      respond_to do |format|
        format.html { raise ex }
        format.xml { error_xml 205  }
      end
    end
  end
  

end
