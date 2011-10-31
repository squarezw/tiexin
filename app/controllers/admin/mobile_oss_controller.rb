class Admin::MobileOssController < ApplicationController
  before_filter :authenticated
  before_filter :find_or_initialize_mobile_os, :except => [:index]
  
  layout "admin"  
  
  
  def index
    @mobile_oss = MobileOs.paginate :order => " id desc",:page => params[:page],:per_page => 10
  end

  def create
    @mobile_os = MobileOs.new(params[:mobile_os])
    if @mobile_os.save
      flash[:notice] = _('Mobile OS was successfully created.')
      redirect_to manage_mobile_oss_path
    else
      render :action => 'new'
    end
  end

  def update
    if @mobile_os.update_attributes(params[:mobile_os])
      flash[:notice] = _('Mobile Model was successfully updated.')
      redirect_to manage_mobile_oss_path
    else
      render :action=>'edit'
    end
  end

  def destroy
    @mobile_os.destroy
    redirect_to manage_mobile_oss_path
  end
  
  protected
  def find_or_initialize_mobile_os
    @mobile_os = params[:id] ? MobileOs.find(params[:id]) : MobileOs.new
  end
  
end
