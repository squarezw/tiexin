class Admin::CouponTemplatesController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'default'
  
  def index
    @templates = CouponTemplate.find :all
  end
  
  def new
    @coupon_template = CouponTemplate.new
  end
  
  def create
    @coupon_template = CouponTemplate.new params[:coupon_template]
    if @coupon_template.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @coupon_template = CouponTemplate.find params[:id]
  end
  
  def update
    @coupon_template = CouponTemplate.find params[:id]
    if @coupon_template.update_attributes params[:coupon_template]
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @coupon_template = CouponTemplate.find params[:id]
    @coupon_template.destroy
    redirect_to :action => "index"
  end
end
