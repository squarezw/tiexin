class CouponTemplate < ActiveRecord::Base
  validates_presence_of :content
  validates_length_of :content, :maximum=>30, :allow_nil=>true
end
