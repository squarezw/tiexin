class RecommendedHotSpotsController < ApplicationController
  before_filter :authenticated
  layout 'default'
  
  helper 'hot_spots', 'layout_maps'
  
  def index
    @member = @current_user
    if @mobile_user
      parse_start_limit
    else
      @page = params[:page]
      @per_page = 10
    end
    if params[:city_id]
      @recommendations = RecommendedHotSpot.paginate :conditions=>['member_id = ? and hot_spots.city_id = ?', @current_user.id, params[:city_id]], :include=>'hot_spot', :order=>'last_recommended_at', :per_page=>@per_page, :page => @page
    else  
      @recommendations = RecommendedHotSpot.paginate_by_member_id @current_user.id,
            :order=>'last_recommended_at', :per_page=>@per_page, :page => @page
    end
    respond_to do |format|
      format.html
      format.xml { render :layout=>false }
    end
  end
  
  def show
    recommendation = @current_user.friend_recommendations.find params[:id]
    recommendation.readed!  
    redirect_to hot_spot_path(recommendation.hot_spot)
  end
  
  def destroy
    recommendation = @current_user.friend_recommendations.find params[:id]
    recommendation.destroy
    redirect_to :action=>:index
  end
end
