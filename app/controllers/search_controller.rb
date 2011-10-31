require 'dynamic_query'
#require 'search_server_proxy'

class SearchController < ApplicationController
  include Imon::DynamicQuery
  
  before_filter :find_city
  after_filter :write_log, :only=>:search
  layout 'default'
  helper 'cities'
  helper 'hot_spots'
  helper 'areas'
  helper 'map_blocks'
  helper 'layout_maps'
  helper 'hot_spot_categories'
  
  def search
    parse_parameters
    return if no_condition 
    
    if !@mobile_user and @tag 
      show_tag
    else
      if @area_name.nil?
        unless @mobile_user or @keyword.nil?
          search_traffic_lines
          search_brands 
          search_tags
          search_roads
        end
      else
        search_areas
        @result_code = 202 if @areas.empty? and @mobile_user
      end
    
      unless @keyword.nil? and 
             (params[:hot_spot_category_id].nil? or params[:hot_spot_category_id].empty?) and
             !has_condition_for_nearby_search? and
             @brand_id.nil?
        @hot_spot_category_id = params[:hot_spot_category_id]
        @hot_spots_count, @hot_spots = search_hot_spots 
        @show_page_navigator = false
        @result_code = 204 if (@hot_spots.nil? or @hot_spots.empty?) and @mobile_user
      end
    end
    
    correct_keyword unless @mobile_user
    
    if request.xhr?
	    render :template=>'/search/search.rjs', :layout=>false
    else
    	respond_to do |format|
        format.html {
          render :template=>'/cities/gmap'
        }        
     		format.xml { render :action=>'mobile_search', :layout=>false }
      end
    end
  end
  
  def search_all
    self.send "search_all_#{params[:category]}"
    @show_page_navigator = true
  end
  
  def advanced_search
    @x = params[:x] ? params[:x].to_i : @current_city.start_point_x
    @y = params[:y] ? params[:y].to_i : @current_city.start_point_y
    if request.get?
      @scope_mode = 'nearby'
      render :layout=>false
    else
      do_advanced_search
    end
  end
  
  def search_nearby
    hot_spot = HotSpot.find params[:hot_spot_id]
    adjust_current_city hot_spot.city
    @x, @y = hot_spot.x, hot_spot.y
    render :layout=>false
  end
  
  def show_brand
    @brand = Brand.find params[:brand_id]
    @hot_spots = HotSpot.paginate_by_city_id_and_brand_id @current_city.id, params[:brand_id],
                                 :order => "name_#{@current_lang}" ,
                                 :page=>params[:page]
  end
  
  def show_tag
    @tag = params[:tag]
    @show_page_navigator = true
    @hot_spots = HotSpot.paginate :conditions=>['city_id = ? and exists (select * from hot_spot_tags t where t.hot_spot_id = hot_spots.id and t.tag = ?)', @current_city.id, @tag],
                                 :order => "name_#{@current_lang}",
                                 :page=>params[:page],
                                 :per_page=>10
  end
  
  private
  def find_city
    begin
      @city = City.find params[:id]    
      adjust_current_city @city
    rescue ActiveRecord::RecordNotFound => ex
      respond_to do |format|
        format.html { raise ex }
        format.xml { error_xml 205  }
      end
    end
  end
  
  def parse_parameters
    parse_area_name
    parse_keyword
    parse_start_limit
    parse_tag
    parse_brand_id
  end
  
  def parse_start_limit
    if @mobile_user
      @start = params.has_key?(:start) ? params[:start].to_i : 0
      @limit = params.has_key?(:limit) ? params[:limit].to_i : 100
      @start = 0 if @start < 0
      @limit = 100 if @limit < 0 or @limit > 100
    else
      @start = 0
      @limit = 5
    end
  end
  
  def parse_area_name
    @area_name = nil
    unless params[:area].nil?
      @area_name = params[:area].is_a?(Hash) ? params[:area][:name] : params[:area]
      @area_name = @area_name.strip
      @area_name = nil if @area_name == 'Area name, road name, hot spot name' or @area_name == _('Area name, road name, hot spot name')
    end
    @area_name = nil if @area_name == ''
  end
  
  def parse_keyword
    @keyword = (params[:keyword] || '').strip
    @keyword = nil if @keyword == 'HotSpot name, brand name, traffice line name, hot spot category name or road name.' or
                      @keyword == _('HotSpot name, brand name, traffice line name, hot spot category name or road name.') or
                      @keyword == ''
  end
  
  def parse_tag
    @tag = params[:tag] unless params[:tag].nil? or params[:tag].empty?
  end
  
  def parse_brand_id
    @brand_id = params[:brand_id].to_i unless params[:brand_id].nil? or params[:brand_id].empty?
  end
  
  def no_condition
    if @area_name.nil? and @keyword.nil? and @tag.nil? and !has_condition_for_nearby_search? and 
        (params[:brand_id].nil? or params[:brand_id].empty?)
      respond_to do |format|
        format.html { 
            flash[:note] = _('Please input search condition')
            redirect_to main_path
          }
        format.js {
          render :update do |page|
            page.alert  _('Please input search condition')
          end
        }
        format.xml {
          error_xml 203
        }
      end
      return true
    end
    return false
  end
  
  def search_areas
    conditions = conditions_for_multilingual_attribute(:name, @area_name)
    @areas_count = @current_city.areas.count(:conditions=> conditions)
    options = {:conditions=>conditions, :order=>"name_#{@current_lang}"}
    options[:limit]= @limit unless @mobile_user
    @areas = @current_city.areas.find(:all, options)
  end
  
  def search_traffic_lines
    conditions = conditions_for_multilingual_attribute :name, @keyword
    @traffic_lines_count = @current_city.traffic_lines.count(:conditions => conditions )
    @traffic_lines = @current_city.traffic_lines.find(:all, :conditions=>conditions, :order => "name_#{@current_lang}", :limit=>@limit)
  end
  
  def search_brands
    conditions = conditions_for_multilingual_attribute(:name, @keyword)
    @brands_count = Brand.count :conditions=>conditions
    @brands = Brand.find :all, :conditions => conditions, :order => "name_#{@current_lang}", :limit=>@limit
  end
  
  def search_tags
    keyword = "%#{@keyword}%"
    quoted_keyword = HotSpotTag.connection.quote "%#{@keyword}%"
    @tags_count = HotSpotTag.count_by_sql ["select count(*) from (select distinct tag from hot_spot_tags t, hot_spots h where t.hot_spot_id = h.id and h.city_id = ? and t.tag like ?) t1 ", @current_city.id, keyword]
    @tags = HotSpotTag.find_by_sql "select distinct t.tag from hot_spot_tags t inner join hot_spots h on (t.hot_spot_id = h.id) where t.tag like #{quoted_keyword} and h.city_id = #{@current_city.id} order by t.tag limit #{@limit}"
  end
  
  def search_roads
    conditions = conditions_for_multilingual_attribute(:name, @keyword)
    @roads_count = @current_city.roads.count :conditions=>conditions
    @roads = @current_city.roads.find :all, :conditions=>conditions, :limit=>@limit
  end
  
  def search_hot_spots
     spec = search_hot_spot_spec
     result_number = HotSpot.count_by_spec @current_city, spec
     if has_condition_for_nearby_search?
       order = "distance(hot_spots.x, hot_spots.y, #{params[:x]}, #{params[:y]})" 
     else
       order = "char_length(hot_spots.name_#{@current_lang}),hot_spots.updated_at"
     end
     hot_spots = HotSpot.search @current_city, spec, {:order=>order, :per_page=>@limit, :page=>@start/@limit+1, :select=>'hot_spots.*'} 
     [result_number, hot_spots]
  end
  
  def search_hot_spot_spec
    or_spec = {}
    spec = {}
    or_spec.merge! :name => @keyword, :tag=>@keyword unless @keyword.nil? 
    if params[:hot_spot_category_id] and !params[:hot_spot_category_id].empty?   
       spec[:hot_spot_category] = params[:hot_spot_category_id]
    else
       or_spec[:hot_spot_category_name] = @keyword unless @keyword.nil?
    end
    spec[:or] = or_spec unless or_spec.empty?
    if params.has_key? :x and
       params.has_key? :y and 
       params.has_key? :scope
      spec[:nearby] = {:x=>params[:x].to_i, :y=>params[:y].to_i, :scope=>params[:scope].to_f}
    end
    spec[:search_in] = @area_name  unless @area_name.nil? or @area_name.empty?
    spec[:brand_id] = params[:brand_id] unless @brand_id.nil?
    spec
  end
  
  def find_road(name)
    return @current_city.roads.find(:first, :conditions=>['name_zh_cn = ? or name_en = ?', name, name])
  end
  
  def find_center_hot_spot(name)
    return @current_city.hot_spots.find(:first, :conditions=>['name_zh_cn = ? or name_en = ?', name, name])
  end
  
  def search_all_hot_spot
    parse_parameters
    unless @area_name.nil? or @area_name.blank?
      search_areas
    end
    
    spec = search_hot_spot_spec
    @hot_spots = HotSpot.search @current_city, spec, {:order=>"char_length(hot_spots.name_#{@current_lang}), hot_spot_categories.order_weight desc, hot_spots.updated_at", :per_page=>10, :page=>params[:page], :select=>'hot_spots.*', :include=>'hot_spot_category'} 
    render :action => 'paginate_hot_spots', :layout=>false
  end
  
  def search_all_area
    @area_name = params[:area].is_a?(Hash) ? params[:area][:name] : params[:area]
    kw = "%#{@area_name}%"
    @areas = Area.paginate :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ?)', @current_city.id, kw, kw], :order => "name_#{@current_lang}", :page=>params[:page], :per_page=>10
    render :action => 'paginate_areas', :layout=>false
  end
  
  def search_all_road
    kw = "%#{params[:keyword]}%"
    @roads = Road.paginate :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ? )', @current_city.id, kw, kw], :page=>params[:page], :order=>"name_#{@current_lang}", :per_page=>20
    render :action=>'paginate_roads', :layout=>false
  end
  
  def search_all_traffic_line
    kw = "%#{params[:keyword].strip}%"
    @traffic_lines = TrafficLine.paginate :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ?)', @current_city.id, kw, kw], :order => "name_#{@current_lang}", :per_page=>20, :page=>params[:page]
    render :action => 'paginate_traffic_lines', :layout=>false
  end
  
  def search_all_tag
    @keyword = HotSpotTag.connection.quote "%#{params[:keyword].strip}%"
    @tags = HotSpotTag.paginate_by_sql "select distinct t.tag from hot_spot_tags t inner join hot_spots h on (t.hot_spot_id = h.id) where t.tag like #{@keyword} and h.city_id = #{@current_city.id} order by t.tag", :page=>params[:page], :per_page=>10
    render :action=>'paginate_tags', :layout=>false
  end
  
  def conditions_for_multilingual_attribute(attribute, keyword)
    kw = "%#{keyword}%"              
    ["#{attribute}_en like ? or #{attribute}_zh_cn like ?", kw, kw]    
  end
  
  def do_advanced_search
    done = false
    catch (:error) do
      spec = { :name=> params[:keyword],
               :tag => params[:tag] }
      spec[:hot_spot_category] = params[:hot_spot_category_id] unless params[:hot_spot_category_id] == 'all'            

      @scope_mode = params[:scope_mode] or 'all'
      case @scope_mode
        when /area/i
          if params[:area][:name].empty?
            @error_msg = _('Please input area name.')
            throw :error
          else
            spec[:area_name] = params[:area][:name]
          end
        when /nearby/i
          scope = params[:scope] ? params[:scope].to_f : 0.2
          spec[:nearby] = { :x=>@x, :y=>@y, :scope=>scope }
      end
      
      if spec.empty?
        @error_msg = _('Please input some criteria to search.')
        throw :error
      end
      
      if params[:score_type]
          order = "#{params[:score_type]} desc"
      else
          order = "name_#{@current_lang}"
      end
      
      @hot_spots = HotSpot.search @current_city, spec, :order=>order, :page=>params[:page], :per_page=>10
      render :action => 'paginate_hot_spots', :layout=>false
      done = true
    end
    unless done
      render :update do |page|
        page.replace_html 'form_error', @error_msg
        page.call 'dialog.show'
      end
    end
  end
  
  def has_condition_for_nearby_search?
    return params.has_key?(:x) && params.has_key?(:y) && params.has_key?(:scope)
  end
  
  def write_log
    SearchLog.create :area=>@area_name,
                     :keyword=>@keyword,
                     :member=>(@current_user ? @current_user : nil),
                     :city=>@current_city,
                     :from_mobile=>@mobile_user,
                     :hot_spot_count=>@hot_spots_count
  end
  
  def correct_keyword
    @correct_keyword = XNavi::SearchServerProxy.instance.correct @keyword, @current_city
    @correct_keyword = nil if @correct_keyword == @keyword or @correct_keyword == 'NULL'
    puts "@correct_keyword = #{@correct_keyword}"
  end
end
