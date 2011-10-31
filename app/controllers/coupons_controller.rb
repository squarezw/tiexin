class CouponsController < ApplicationController
  before_filter :authenticated
  
  def apply
    coupon = Coupon.find params[:id]
    if coupon.can_apply_by?(@current_user)
      coupon.apply_by(@current_user)
      flash[:note] = _('You have gotten this coupon. You can view and print in "Received Coupons" section of "My-XNavi"')
    else
      flash[:note] = _('You can not apply coupon of this event now.')
    end
    redirect_to request.env['HTTP_REFERER']
  end
end
