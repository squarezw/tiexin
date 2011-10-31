class MobileModelsController < ApplicationController
  def index
    mobile_brand_id =  params[:mobile_brand_id].to_i
    @mobile_models = MobileModel.paginate :order => " id desc",:page => params[:page],:per_page => 36, :conditions => ["mobile_brand_id = ?",mobile_brand_id]
  end
  
  def show
    @mobile_model = MobileModel.find(params[:id])
    render :template => "/admin/mobile_models/show"
  end
end
