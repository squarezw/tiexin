class FavoritesController < ApplicationController
  layout 'default', :only => 'index'
  
  before_filter :find_member, :only=>[:index]
  before_filter :authenticated, :only=>[:create,:destroy]
  before_filter :open_authenticated, :only=>[:index]
  helper 'hot_spots'
  helper 'layout_maps'
  
  def index
    respond_to do |format|
      format.html {
          @hot_spots = HotSpot.paginate :conditions => ['id in (select hot_spot_id from hot_spots_members where member_id = ?)', @member.id],
                                 :order => "name_#{current_lang}",
                                 :page=>params[:page]
      } 
      
      format.xml {
        parse_start_limit
        if params[:city_id]
          conditions = ['id in (select hot_spot_id from hot_spots_members where member_id = ?) and city_id = ?', @member.id, params[:city_id]]
        else
          conditions = ['id in (select hot_spot_id from hot_spots_members where member_id = ?)', @member.id]
        end
        @hot_spots = HotSpot.paginate :conditions => conditions, :order => "name_#{current_lang}", :page=>@page, :per_page=>@per_page
        render :layout=>false
      }
    end
  end
  
  def create
    unless @current_user.have_favorite(params[:hot_spot_id])
       @current_user.hot_spots << HotSpot.find(params[:hot_spot_id])
    end
    @msg = _('The hot spot has already been added to your favorite')
    respond_to do |format|
      format.html
      format.xml
      format.js
    end
  end
  
  def destroy
    @current_user.hot_spots.delete HotSpot.find(params[:hot_spot_id])
    respond_to do |format|
      format.html { redirect_to member_favorites_path(params[:member_id]) }
      format.xml { error_xml 100 }
    end
  end
  
  protected
  def open_authenticated
      if @mobile_user
        authenticate_or_request_with_http_basic do |username, password| 
          logger.info "http basic authentication: '#{username}', '#{password}'"
          @current_user = Member.login(username, password) 
        end
        @member = @current_user
        return ! @current_user.nil?
      else
        return true if @member == @current_user || (@member.favorite_open_option == 2 && @current_user.has_friend?(@member)) || @member.favorite_open_option == 3
        flash[:note] = _('You have no privilege to do this operation.')
        redirect_to member_path(params[:member_id])
        return false
      end
  end
  
  private
  
  def find_member
    @member = Member.find(params[:member_id])
  end
  
end