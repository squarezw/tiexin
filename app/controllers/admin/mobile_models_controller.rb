class Admin::MobileModelsController < ApplicationController
  before_filter :authenticated
  before_filter :find_or_initialize_mobile_model, :except => [:index]
  
  layout "admin"  
  
  helper :mobile_models

  def index
    @mobile_models = MobileModel.paginate :order => " id desc",:page => params[:page], :per_page => 24
  end

  def create
    @mobile_model = MobileModel.new(params[:mobile_model])
    if @mobile_model.save
      flash[:notice] = _('Mobile Model was successfully created.')
      redirect_to manage_mobile_models_path
    else
      render :action => 'new'
    end
  end

  def update
    if @mobile_model.update_attributes(params[:mobile_model])
      flash[:notice] = _('Mobile Model was successfully updated.')
      redirect_to manage_mobile_models_path
    else
      render :action=>'edit'
    end
  end

  def destroy
    @mobile_model.destroy
    redirect_to manage_mobile_models_path
  end
  
  protected
  def find_or_initialize_mobile_model
    @mobile_model = params[:id] ? MobileModel.find(params[:id]) : MobileModel.new
  end
  
end
