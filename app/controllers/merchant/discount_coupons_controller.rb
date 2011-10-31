class Merchant::DiscountCouponsController < ApplicationController
  before_filter :authenticated
  before_filter :find_vendor, :only=>[:new, :create]
  before_filter :check_privilege, :only=>[:new, :create]
  layout 'default'
  
  def index
    @discount_coupons = DiscountCoupon.paginate :conditions=>['member_id = ? and expire_at >= ?', @current_user.id, Date.today], :order=>'created_at', :page=>params[:page]
  end
  
  def show
    @discount_coupon = @current_user.coupons.find params[:id]
  end
  
  def new
    @discount_coupon = DiscountCoupon.new
  end
  
  def edit
    @discount_coupon = DiscountCoupon.find params[:id]
    @vendor = @discount_coupon.vendor
    unless @discount_coupon.modifiable?
      flash[:note] = _('You can not modify this discount coupon now.')
      redirect_to request.env['HTTP_REFERER']
      return
    end
  end
  
  def create
    @discount_coupon = DiscountCoupon.new params[:discount_coupon]
    @discount_coupon.vendor = @vendor
    @discount_coupon.member = @current_user
    if params[:submit_now] == '1'
      @discount_coupon.status = DiscountCoupon::STATUS_WAITING_APPROVE
    else
      @discount_coupon.status = DiscountCoupon::STATUS_NEW
    end
    @discount_coupon.cities << City.find(params[:cities]) if params[:cities]
    if @discount_coupon.save        
      process_after_save
      redirect_to @vendor
    else
      render :action=>:new
    end
  end
  
  def update
    @discount_coupon = DiscountCoupon.find params[:id]
    unless @discount_coupon.modifiable?
      flash[:note] = _("You can not modify this coupon now.")
      redirect_to :action=>:index
      return
    end
    @discount_coupon.cities.clear
    @discount_coupon.cities = City.find(params[:cities]) if params[:cities]
    if @discount_coupon.update_attributes params[:discount_coupon]
      if @discount_coupon.can_submit_now?
        @discount_coupon.submit! if params[:submit_now] == '1'
        process_after_save
      else
        flash[:note] = _('The modification has been saved, but you can not submit this coupon for approve now.')
      end
      redirect_to :action=>:index
    else
      render  :action=>:new
    end
  end

  def submit
    @discount_coupon = DiscountCoupon.find params[:id]
    if @discount_coupon.can_submit_now?
      @discount_coupon.submit!
      process_after_save
    else
      flash[:note] = _('You can not submit this coupon for approve now.')
    end
    redirect_to :action=>:show
  end
  
  def preview
    @discount_coupon = DiscountCoupon.find params[:id]
    render :layout=>'print'
  end
  
  def destroy
    @discount_coupon = DiscountCoupon.find params[:id]
    if @discount_coupon.can_delete?
      @discount_coupon.destroy
      redirect_to :action=>:index
    else
      flash[:note] = _('You can not delete this coupon now.')
      redirect_to :action=>:show
    end
  end
  
  private
  def find_vendor
    vendor_class = params[:vendor_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @vendor = vendor_class.send(:find, params[:vendor_id])
  end
  
  def check_privilege
    return true if @current_user and (@vendor.owner == @current_user or @current_user.has_privilege(:manage_coupons))
    flash[:note] = _("You have no privilege to do this operation.")
    redirect_to @vendor
  end
  
  def process_after_save
    if @current_user.has_privilege(:manage_coupons) and 
      @discount_coupon.status == DiscountCoupon::STATUS_WAITING_APPROVE
      DiscountCoupon.transaction do 
        @discount_coupon.approve!(@current_user)
        @discount_coupon.event = @discount_coupon.create_event
        @discount_coupon.event.save_with_validation false
        @discount_coupon.save_with_validation false
      end
    end
    case @discount_coupon.status
    when DiscountCoupon::STATUS_WAITING_APPROVE
      flash[:note] = _('The discount coupon has been submitted for approve by administrator.')
    when DiscountCoupon::STATUS_APPROVED
      flash[:note] = _('The discount has been issued for user to apply.')
    when DiscountCoupon::STATUS_NEW
      flash[:note] = _('The discount coupon has been saved.')
    end
  end
end
