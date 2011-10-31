class HotSpotCategoriesController < ApplicationController
  before_filter :find_city, :only=>[:show]
  layout  'default', :only => [:show]
  
  helper 'promotions'
  helper 'hot_spots'
  helper 'layout_maps'
  
  def index
    respond_to do |format|
      format.html { render :action=>'categories', :layout=>'default' }
      format.xml { index_xml }
    end
  end
  
  def show
    @channel = Channel.find_by_hot_spot_category_id params[:id]
    if @channel
      redirect_to city_channel_path(@current_city, @channel)
      return
    end
    
    if params[:score_type]
      order = "#{params[:score_type]} desc"
    else
      order = "name_#{@current_lang}"
    end
    @hot_spot_category = HotSpotCategory.find params[:id]
    @hot_spots = HotSpot.paginate :conditions => ['hot_spot_category_id = ? and city_id = ?', @hot_spot_category.id, @current_city.id], :order=>order, :page=>params[:page], :per_page=>10
  end

  def children
    @category = HotSpotCategory.find(params[:id])
    @manage_category = params[:manage]
  end

  private 
  def find_city
    adjust_current_city City.find(params[:city_id])
  end

  def index_xml
    if params.has_key? :last_download_at
       last_download_at = Time.parse params[:last_download_at]
       logger.info "last_download_at = #{last_download_at}"
       a=HotSpotCategory.connection.select_one 'select max(created_at), max(updated_at) from hot_spot_categories'
       if last_download_at >= Time.parse(a.values.max)
         error_xml 101
         return
       end
     end
    @roots = HotSpotCategory.roots 'id'
  end
end
