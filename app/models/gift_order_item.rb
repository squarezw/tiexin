class GiftOrderItem < ActiveRecord::Base
  belongs_to :gift_order
  belongs_to :gift
  
  validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to=>1, :message=>'必须大于0.'
end
