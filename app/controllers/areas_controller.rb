class AreasController < ApplicationController
  layout 'default', :only => [:show, :index] 
  before_filter :find_city
  before_filter :find_area, :except=>[:index]
  helper :hot_spot_categories
  
  def index
    @areas = Area.paginate_by_city_id @current_city.id,
                             :order =>"name_#{@current_lang}", :per_page=>50, :page=>params[:page]
  end
  
  def show
    @area.visited!
    @roots = HotSpotCategory.roots
  end
  
  def hot_spot_category
    @category = HotSpotCategory.find(params[:category_id])
    @category_ids =  @category.id_of_all_children_include_self.join(',')
    @hot_spots = HotSpot.paginate :conditions => ["(x between ? and ?) and (y between ? and ?) and hot_spot_category_id in (#{@category_ids}) and city_id = ?", 
                            @area.nw_x, @area.nw_x + @area.width, @area.nw_y, @area.nw_y + @area.height, @area.city_id ],
                            :order=>"name_#{current_lang}",
                            :page=>params[:page]
  end

  private
  def find_area
    @area = @current_city.areas.find params[:id]
  end
  
  def find_city
    adjust_current_city City.find(params[:city_id])
  end
end
