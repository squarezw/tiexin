class ReceivedCoupon < ActiveRecord::Base
  belongs_to :member
  belongs_to :coupon
  
  validates_presence_of :member
  validates_presence_of :coupon
  validates_presence_of :name
  validates_length_of :name, :maximum=>10, :allow_nil=>true
  
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum=>15, :allow_nil=>true
  
  def copy_member_info(member)
    self.name = member.real_name[0..9] unless member.real_name.nil?
    self.phone_number = member.mobile_phone
  end
  
end
