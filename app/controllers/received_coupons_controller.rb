class ReceivedCouponsController < ApplicationController
  before_filter :authenticated
  layout 'default', :except=>[:new, :create]
  
  def index
    @received_coupons = ReceivedCoupon.paginate :include=>:coupon, :conditions=>['received_coupons.member_id = ? and coupons.expire_at > ?', @current_user.id, Date.today], :page=>@page, :per_page=>10, :order=>'received_coupons.created_at desc'
  end
  
  def show
    @received_coupon = @current_user.received_coupons.find params[:id]
  end
  
  def new
    @coupon = Coupon.find params[:coupon_id]
    @received_coupon = ReceivedCoupon.new
    @received_coupon.copy_member_info @current_user
  end
  
  def create
    @coupon = Coupon.find params[:coupon_id]
    @received_coupon = ReceivedCoupon.new params[:received_coupon]
    @received_coupon.coupon = @coupon
    @received_coupon.member = @current_user
    unless @received_coupon.save
      render :action=>:new
    end
  end
  
  def print
    unless params[:received_coupons] and params[:received_coupons].is_a?(Hash) and !params[:received_coupons].empty?
      flash[:note] = _('Please select at least one coupon.')
      redirect_to :action=>:index
    end
    
    @received_coupons = params[:received_coupons].keys.collect { |id| @current_user.received_coupons.find id }
    render :layout=>'print'
  end
end
