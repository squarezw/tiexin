require 'dynamic_query'
class MainController < ApplicationController
  include Imon::DynamicQuery
  
  layout 'default'
  helper 'hot_spots'
  helper 'areas'
  helper 'layout_maps'

  def map
    do_fast_search if params.has_key?(:keyword)
    @hot_spot = HotSpot.find(params[:hot_spot_id]) if params.has_key?(:hot_spot_id)
    @area = Area.find(params[:area_id]) if params.has_key?(:area_id)
  end                 
  
  def advanced_search
    @x = params[:x] ? params[:x].to_i : @current_city.start_point_x
    @y = params[:y] ? params[:y].to_i : @current_city.start_point_y
    if request.get?
      @scope_mode = 'all'
      render :layout=>false
    else
      do_advanced_search
    end
  end
  
  def show_all_result
    keyword = params[:keyword]  
    unless keyword.nil? or keyword.empty?
      method = "show_all_#{params[:category]}_result"
      logger.info "self.respond_to?(#{method}): #{self.respond_to?(method, true)}"
      self.send(method) if self.respond_to?(method, true)    
    else  
      render :nothing=>true, :status=>200
    end
  end
  
  def traffic_line
    @traffic_line = @current_city.traffic_lines.find(params[:id])
  end
  
  def owner_explanation
    render :layout=>'simple'
  end
  
  private
  def search_hot_spot(conditions)
    count = @current_city.hot_spots.count(:conditions => conditions)
    hot_spots = @current_city.hot_spots.find(:all, 
      :conditions=>conditions, :limit=>5)
    return [count, hot_spots]
  end
  
  def search_area(conditions)
    count = @current_city.areas.count(:conditions=> conditions)
    areas = @current_city.areas.find(:all, :conditions=>conditions, :order=>"name_#{@current_lang}", :limit => 5 )
    return [count, areas]
  end
  
  def search_traffic_lines(conditions)
    count = @current_city.traffic_lines.count(:conditions => conditions )
    lines = @current_city.traffic_lines.find(:all, :conditions=>conditions, :order => "name_#{@current_lang}", :limit=>5)
    return [count, lines]
  end
  
  def show_all_hot_spot_result
    kw = "%#{params[:keyword]}%"
    @page, @hot_spots = paginate :hot_spots, 
                                 :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ?)', @current_city.id, kw, kw],
                                 :order => "name_#{@current_lang}"
    render :template => 'main/paginate_hot_spots.rjs', :layout=>false
  end
  
  def show_all_area_result
    kw = "%#{params[:keyword]}%"
    @page, @areas = paginate :areas, 
                                 :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ?)', @current_city.id, kw, kw],
                                 :order => "name_#{@current_lang}"
    render :template => 'main/paginate_areas.rjs', :layout=>false
    
  end

  def show_all_traffic_line_result
    kw = "%#{params[:keyword]}%"
    @page, @traffic_lines = paginate :traffic_lines, 
                                 :conditions=>['city_id = ? and (name_zh_cn like ? or name_en like ?)', @current_city.id, kw, kw],
                                 :order => "name_#{@current_lang}"
    render :template => 'main/paginate_traffic_lines.rjs', :layout=>false
  end

  def build_conditions(keyword)
    kw = "%#{keyword}%"              
    ["name_en like ? or name_zh_cn like ?", kw, kw]    
  end
  
  def do_fast_search
    keyword = params[:keyword]                                                      
    unless keyword.nil? or keyword.empty?
      conditions = build_conditions(keyword)
      @areas_count, @areas = search_area conditions
      @hot_spots_count, @hot_spots=search_hot_spot conditions
      @traffic_lines_count, @traffic_lines=search_traffic_lines conditions
      @has_search_result = true
    end
  end
  
  def do_advanced_search
    done = false
    catch (:error) do
      exps = [self.equal :city_id, @current_city.id]
      keyword = params[:keyword] or ''
      unless keyword.blank?
        keyword = params[:keyword]
        exps << self.or(self.like (:name_zh_cn, keyword), self.like(:name_en, keyword))
      end
      
      @scope_mode = params[:scope_mode] or 'all'
      case @scope_mode
        when /area/i
          exps << expression_for_area
        when /nearby/i
          exps << expression_for_nearby
      end
      
      if params[:hot_spot_category_id] and !params[:hot_spot_category_id].blank? and ! (params[:hot_spot_category_id] =~ /all/i)
        exps << expression_for_hot_spot_category
      end
      
      if exps.empty?
        @error_msg = _('Please input some criteria to search.')
        throw :error
      end
      
      condition = self.and(exps).conditions
      condition = condition[0] if condition.length == 1
      @page, @hot_spots = paginate :hot_spots,
                                   :conditions=> condition,
                                   :order => "name_#{@current_lang}" 
      render :template => 'main/paginate_hot_spots.rjs', :layout=>false
      done = true
    end
    unless done
      render :update do |page|
        page.replace_html 'form_error', @error_msg
        page.call 'dialog.show'
      end
    end
  end

  def expression_for_area
    if params[:area].empty?
      @error_msg = _('Please input area name.')
      throw :error
    else
      area = "%#{params[:area]}%"
      self.raw("exists (select * from areas a where ((a.name_zh_cn like '#{area}') or (a.name_en like '#{area}')) and a.nw_x <= hot_spots.x and a.nw_x + a.width >= hot_spots.x and a.nw_y <= hot_spots.y and a.nw_y + a.height >= hot_spots.y)")
    end
  end
  
  def expression_for_nearby
    scope = params[:scope] ? params[:scope].to_f : 0.2
    scope = [[2, scope].min, 0.2].max
    self.raw("sqrt( pow((x-#{@x}) * 0.007692 , 2) + pow((y - #{@y}) * 0.007692, 2) ) <= #{scope * 1000}")
  end
  
  def expression_for_hot_spot_category
    cat_id = params[:hot_spot_category_id].to_i
    cat_ids = HotSpotCategory.find(cat_id).all_children_include_self.collect { |cat| cat.id }
    raw("hot_spot_category_id in (#{cat_ids.flatten.join(',')})")    
  end
end
