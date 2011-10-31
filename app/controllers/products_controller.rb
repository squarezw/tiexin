require 'find_hot_spot'
require 'scores'

class ProductsController < ApplicationController
  include XNavi::Score
  include FindHotSpot
  
  before_filter :is_admin, :only => [:destroy]
  before_filter :find_vendor
  helper 'comments'
  helper 'hot_spot_categories'
           
  layout 'default', :only=>[:index, :show]
  def index
    @products= @vendor.products
    logger.info "@products = #{@products}"
    if @vendor.is_a? HotSpot and @mobile_user and @vendor.brand
      @products+= @vendor.brand.products
    end
    respond_to do |format|
      format.html
      format.xml { render  :layout => false  }
    end
  end
  
  def show
    @product = @vendor.products.find(params[:id])
  end
  
  def new              
    @product = @vendor.products.build()
  end

  def create
    @product = @vendor.products.build(params[:product])   
    @product.creator = @current_user
    if @product.save                  
      score :recommend_product 
      respond_to_parent do
          render :layout=>false
      end
    else                          
      respond_to_parent do
        render :update do |page|
          page.replace_html 'form_error', @product.errors.full_messages.join("<br/>")
          page.call 'dialog.show'
        end
      end
    end
  end

  def edit  
    @product = @vendor.products.find(params[:id])       
  end

  def update 
    @product = @vendor.products.find(params[:id])       
    @product.last_updater = @current_user
    if @product.update_attributes(params[:product])
      respond_to_parent do
        render :layout => false
      end
    else                       
      respond_to_parent do
        render :update do |page|
          page.replace_html 'form_error', @product.errors.full_messages.join("<br/>")
          page.call 'dialog.show'
        end
      end
    end
  end

  def destroy  
    @product = @vendor.products.find(params[:id])   
    @product.destroy
    redirect_to products_path @vendor.class.to_s.underscore, @vendor
  end
  
  private
  def find_vendor
    vendor_class = params[:vendor_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @vendor = vendor_class.send(:find, params[:vendor_id])
  end
  
end
