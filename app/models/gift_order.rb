require 'xnavi_exceptions'

class GiftOrder < ActiveRecord::Base
  DELIVER_SEND = 0
  DELIVER_FETCH = 1
  ALL_DELIVER_METHODS = [DELIVER_SEND, DELIVER_FETCH]
  
  PAYMENT_PAY_ON_RECEIVE = '0'
  
  STATUS_NEW = 0
  STATUS_CONFIRMED = 1
  STATUS_DELIVERING = 2
  STATUS_RECEIVED = 3
  STATUS_PAID = 4
  STATUS_CANCELLED = -1
  
  ALL_STATUS = [STATUS_NEW, STATUS_CONFIRMED, STATUS_DELIVERING, STATUS_RECEIVED, STATUS_PAID, STATUS_CANCELLED]
  
  N_('gift_order_deliver_method|0')
  N_('gift_order_deliver_method|1')
  N_('gift_order_payment_method|0')
  N_('gift_order_status|0')
  N_('gift_order_status|1')
  N_('gift_order_status|2')
  N_('gift_order_status|3')
  N_('gift_order_status|4')
  N_('gift_order_status|-1')
  
  belongs_to :member
  belongs_to :partner
  has_many :gift_order_items, :dependent=>:destroy, :validate=>false
  attr_protected :used_experience, :used_credit, :cash, :status, :confirmed_at, :partner
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>100, :allow_nil=>true
  validates_presence_of :city
  validates_length_of :city, :maximum=>100, :allow_nil=>true
  validates_presence_of :post_code, :if=>:require_deliver_address
  validates_length_of :post_code, :maximum=>10, :allow_nil=>true
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum=>15, :allow_nil=>true
  validates_length_of :phone_number2, :maximum=>15, :allow_nil=>true
  validates_format_of :phone_number, :with=>/^[0-9\-_*]*$/, :allow_nil=>true, :message=>_("The phone number must composed with digital, '-', '_' and '*'")
  validates_format_of :phone_number2, :with=>/^[0-9\-_*]*$/, :allow_nil=>true, :message=>_("The phone number must composed with digital, '-', '_' and '*'")
  validates_presence_of :address, :if=>:require_deliver_address
  validates_length_of :address, :maximum=>300, :allow_nil=>true
  validates_presence_of :certificate_type, :if=>:require_certificate_info
  validates_length_of :certificate_type, :maximum=>30, :allow_nil=>true
  validates_presence_of :certificate_no , :if=>:require_certificate_info
  validates_length_of :certificate_no, :maximum=>30, :allow_nil=>true
  
  _('Gift order items')
  
  def self.per_page
    20
  end
  
  def require_deliver_address
    return self.deliver_method == DELIVER_SEND
  end
  
  def require_certificate_info
    return self.deliver_method == DELIVER_FETCH
  end
  
  def update_total_price!
    total_experience, total_credit, total_cash = 0, 0, 0
    self.gift_order_items.each { |item|
      gift = item.gift
      total_experience += gift.experience * item.quantity
      total_credit += gift.credit * item.quantity
      total_cash += gift.cash * item.quantity
    }
    self.used_experience = total_experience
    self.used_credit = total_credit
    self.cash = total_cash
    self.save!
  end
  
  def affordable_to?(member)
    raise XNavi::NoEnoughPointException if (member.available_experience < self.used_experience || member.available_credit < self.used_credit)
  end
  
  def confirm!
    if self.status == STATUS_NEW
      self.member.use_point self.used_experience, self.used_credit
      self.member.save
      self.status = STATUS_CONFIRMED
      self.confirmed_at = Time.now
      self.save_with_validation false
      save_information_to_member
    end
  end
  
  def delivered!
    if self.status == STATUS_NEW and self.deliver_method == DELIVER_FETCH
      self.confirm!
    end
    
    if self.status == STATUS_CONFIRMED
      if self.deliver_method == DELIVER_FETCH
        self.update_attribute_with_validation_skipping :status, STATUS_RECEIVED
      else
        self.update_attribute_with_validation_skipping :status, STATUS_DELIVERING
      end
      self.update_attribute_with_validation_skipping :delivered_at, Time.now
    end
  end
  
  def copy_information_from_member
    self.name = self.member.real_name
    self.phone_number = self.member.mobile_phone
    self.phone_number2 = self.member.phone_number2
    self.city = self.member.city
    self.address = self.member.address
    self.post_code = self.member.post_code
    self.certificate_type = self.member.certificate_type
    self.certificate_no = self.member.certificate_no
  end
  
  def gift_summary
    (self.gift_order_items.collect { |item| "#{item.gift.name}X#{item.quantity}"}).join(', ')
  end
  
  def modifiable_to?(member)
    member and (self.member_id == member.id or member.is_admin?)
  end
  
  def can_deliver?
    (self.deliver_method == DELIVER_SEND and self.status == STATUS_CONFIRMED) or 
    (self.deliver_method == DELIVER_FETCH and [STATUS_NEW, STATUS_CONFIRMED].include?(self.status))
  end
  
  def visible_to?(member, partner)
    return true if member and (member.is_admin or member.id == self.member_id)
    return (partner and partner.id == self.partner_id)
  end
  
  def can_deliver_by(member, partner)
    return true if member and member.is_admin?
    return (partner and partner.id == self.partner_id)
  end
  
  private
  def save_information_to_member
    attrs = {:real_name => self.name }
    attrs = attrs.merge   :address => self.address,
                          :city => self.city,
                          :post_code => self.post_code ,
                          :certificate_type => self.certificate_type,
                          :certificate_no => self.certificate_no 
    if self.phone_number =~ /^\d{11}$/
      attrs[:mobile_phone] = self.phone_number 
      attrs[:phone_number2] = self.phone_number2 unless self.phone_number2.nil?
    elsif self.phone_number2 =~ /^\d{11}$/
      attrs[:mobile_phone] = self.phone_number2
      attrs[:phone_number2] = self.phone_number
    else
      attrs[:phone_number2] = self.phone_number
    end
    self.member.update_attributes! attrs
  end
end

