class Admin::NaviStarsController < ApplicationController
  before_filter :authenticated, :except => [:check_update]
  before_filter :find_or_initialize_navi_star, :except => [:index]
  
  layout "admin"  
  
  def index
    @navi_stars = NaviStar.paginate :order => " id desc",:page => params[:page],:per_page => 10
  end
  
  def create
    @navi_star = NaviStar.new(params[:navi_star])
    @navi_star.update_release_at
    if @navi_star.save
      flash[:notice] = _('Mobile OS was successfully created.')
      redirect_to manage_navi_stars_path
    else
      render :action => 'new'
    end
  end

  def update
    unless params[:navi_star][:filename].nil? || params[:navi_star][:filename].blank?
      @navi_star.update_release_at
    end
    if @navi_star.update_attributes(params[:navi_star])
      flash[:notice] = _('Mobile Model was successfully updated.')
      redirect_to manage_navi_stars_path
    else
      render :action=>'edit'
    end
  end

  def destroy
    @navi_star.destroy
    redirect_to manage_navi_stars_path
  end
  
  def check_update
    os = params[:os]
    release = params[:release].to_i
    major = params[:major].to_i
    minor = params[:minor].to_i
    mobile_os = MobileOs.find_by_name(os)
    min_version = mobile_os.navi_star.minimum_release*100 + mobile_os.navi_star.minimum_major*10 + mobile_os.navi_star.minimum_minor
    new_vsersion = mobile_os.navi_star.release*100 + mobile_os.navi_star.major*10 + mobile_os.navi_star.minor
    version =   release*100 + major*10 + minor
    if mobile_os and mobile_os.navi_star
      if version < min_version
        @navi_star = mobile_os.navi_star
        @code = 213
      else
        if version == new_vsersion
          @navi_star = nil
        else
          @navi_star = mobile_os.navi_star
        end
        @code = 102
      end
    else
      @navi_star = nil
    end
    respond_to do |format|
      format.xml { render  :layout => false  }
    end
  end
  
  protected
  def find_or_initialize_navi_star
    @navi_star = params[:id] ? NaviStar.find(params[:id]) : NaviStar.new
  end
end
