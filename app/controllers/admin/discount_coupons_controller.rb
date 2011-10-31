require 'privilege'
class Admin::DiscountCouponsController < ApplicationController
  include XNavi::Privilege
  
  before_filter :authenticated
  before_filter :is_admin
  layout 'default' 
  
  require_privilege :index, :manage_coupons
  require_privilege :show, :manage_coupons
  
  def index
    @discount_coupons = DiscountCoupon.paginate_by_status DiscountCoupon::STATUS_WAITING_APPROVE, :page=>params[:page], :per_page=>20
  end
  
  def show
    @discount_coupon = DiscountCoupon.find params[:id]
  end
  
  def approve
    @discount_coupon = DiscountCoupon.find params[:id]
    if @discount_coupon.can_approve_now?
      DiscountCoupon.transaction do 
        @discount_coupon.approve!(@current_user)
        @discount_coupon.event = @discount_coupon.create_event
        @discount_coupon.event.save_with_validation false
        @discount_coupon.save_with_validation false
      end
      flash[:note] = _('The discount coupon has been approved.')
      redirect_to :action=>:index
    else
      flash[:note] = _('You can not approve or disapprove this discount coupon now.')
      redirect_to :action=>:index
    end
  end
  
  def disapprove
    @discount_coupon = DiscountCoupon.find params[:id]
    if @discount_coupon.can_approve_now?
      @discount_coupon.disapprove!(@current_user)
      flash[:note] = _('The discount coupon has been disapproved and return back to vendor to modify.')
      redirect_to :action=>:index
    else
      flash[:note] = _('You can not approve or disapprove this discount coupon now.')
      redirect_to :action=>:index
    end
  end
end
