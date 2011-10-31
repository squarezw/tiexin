class Admin::MobileBrandsController < ApplicationController
  before_filter :authenticated
  before_filter :find_or_initialize_mobile_brand, :except => [:index]
  
  layout "admin"  
  
  helper :mobile_brands
  
  def index
    @mobile_brands = MobileBrand.paginate :page => params[:page],:per_page => 10
  end
  
  def create
    @mobile_brand = MobileBrand.new(params[:mobile_brand])
    if @mobile_brand.save
      flash[:notice] = _('Mobile Brand was successfully created.')
      redirect_to manage_mobile_brands_path
    else
      render :action => 'new'
    end
  end

  def update
    if @mobile_brand.update_attributes(params[:mobile_brand])
      flash[:notice] = _('Mobile Brand was successfully updated.')
      redirect_to manage_mobile_brands_path
    else
      render :action=>'edit'
    end
  end
  
  def destroy
    @mobile_brand.destroy
    redirect_to manage_mobile_brands_path
  end

  protected
  def find_or_initialize_mobile_brand
    @mobile_brand = params[:id] ? MobileBrand.find(params[:id]) : MobileBrand.new
  end
  
end
