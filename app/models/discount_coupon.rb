class DiscountCoupon < Coupon
  STATUS_NEW = 1
  STATUS_WAITING_APPROVE = 2
  STATUS_APPROVED = 3
  STATUS_DISAPPROVED = 4
  MODIFIABLE_STATUS = [STATUS_NEW, STATUS_DISAPPROVED]
  CAN_SUBMIT_STATUS = [STATUS_NEW, STATUS_DISAPPROVED]
  
  _('discount_coupon_status|1')
  _('discount_coupon_status|2')
  _('discount_coupon_status|3')
  _('discount_coupon_status|4')
  _('DiscountCoupon|Summary')
  _('DiscountCoupon|Expire at')
  
  def validate
    self.errors.add :expire_at, _("is required and must be later than today.") if self.expire_at.nil? or self.expire_at < Date.today
  end
  
  def modifiable?
    self.expire_at > Date.today or (MODIFIABLE_STATUS.include?(self.status))
  end
  
  def submit!
    self.update_attribute_with_validation_skipping :status, STATUS_WAITING_APPROVE if self.can_submit_now?
  end
  
  def can_submit_now?
    return self.modifiable?
  end
  
  def can_approve_now?
    self.expire_at > Date.today and STATUS_WAITING_APPROVE == self.status
  end
  
  def approve!(admin)
    if self.can_approve_now?
      self.status = STATUS_APPROVED 
      self.admin = admin
      self.save!
    end
  end
  
  def disapprove!(admin)
    if self.can_approve_now?
      self.status = STATUS_DISAPPROVED
      self.admin = admin
      self.save!
    end
  end
  
  def can_apply_by?(member)
    self.expire_at > Date.today and STATUS_APPROVED == self.status and member != self.member
  end
  
  def apply_by(member)
    self.received_coupons.create :member=>member
  end
  
  def can_delete?
    return MODIFIABLE_STATUS.include? self.status
  end
  
  def create_event
    event = Promotion.create  :vendor=>self.vendor,
                      :member=>self.member,
                      :summary_zh_cn => "[#{_('Discount Coupon')}]#{self.summary}",
                      :summary_en=>'',
                      :content_zh_cn=>self.terms,
                      :begin_date=>Date.today,
                      :end_date=>self.expire_at,
                      :allcity=>self.all_city
    event.cities = self.cities;
    return event            
  end
end
