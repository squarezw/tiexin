class Coupon < ActiveRecord::Base
  belongs_to :vendor, :polymorphic=>true
  belongs_to :member
  belongs_to :admin, :class_name=>'Member', :foreign_key=>'admin_id'
  belongs_to :event
  has_many :received_coupons, :dependent=>:delete_all
  has_and_belongs_to_many :cities
  
  validates_presence_of :summary
  validates_length_of :summary, :maximum=>30, :allow_nil=>true
  validates_length_of :terms, :maximum=>120, :allow_nil=>true
  
  attr_protected :member, :admin, :event, :vendor
  
  def has_applied_by?(member)
    return ReceivedCoupon.exists? ['coupon_id = ? and member_id = ?', self.id, member.id]
  end
  
  def before_save
    if self.vendor.respond_to?(:city)
      self.cities << self.vendor.city
    else
      self.all_city = (self.cities.nil? or self.cities.empty?)  
    end
    return true
  end
end
