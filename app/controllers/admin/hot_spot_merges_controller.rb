require 'privilege'

class Admin::HotSpotMergesController < ApplicationController
  include XNavi::Privilege
  
  before_filter :authenticated
  require_privilege :index, :modify_hot_spot
  require_privilege :create, :modify_hot_spot
  require_privilege :search_target, :modify_hot_spot
  require_privilege :preview, :modify_hot_spot

  before_filter :find_hot_spot
  before_filter :no_layout_maps
    
  
  layout 'admin', :only=>[:index, :preview, :create]
  
  def index
    @keyword = @hot_spot.name[@current_lang]
    do_search("%#{@keyword}%")
    render :action=>'search_target', :layout=>false if request.xml_http_request?
  end
  
  def create
    @target = HotSpot.find params[:target_id]
    HotSpot.transaction do
      if @target.update_attributes(params[:target]) 
        @target.merge_from @hot_spot
      else
        render :action => "preview"
        return
      end
    end
    redirect_to hot_spot_path(@target)
  end
  
  def search_target
    @keyword = params[:keyword]
    do_search("%#{@keyword}%")
  end
  
  def preview
    @target = HotSpot.find params[:target_id]
  end
  
  private 
  def find_hot_spot
    @hot_spot = HotSpot.find params[:hot_spot_id]
    @current_city = @hot_spot.city
    bind_city
  end
  
  def do_search(keyword)
    @targets = HotSpot.paginate :conditions=>['city_id = ? and id <> ? and (name_zh_cn like ?) or (name_en like ?)', @current_city.id, @hot_spot.id, keyword, keyword],
                                :order=>"name_#{@current_lang}",
                                :page=>params[:page]
  end
  
  def no_layout_maps
    unless @hot_spot.layout_maps.empty?
      flash[:note] = _('Hot spot can not be merged when has layout maps.')
      redirect_to hot_spot_path(@hot_spot)
    end
  end
end
