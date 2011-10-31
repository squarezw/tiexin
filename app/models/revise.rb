class Revise < ActiveRecord::Base
  STATUS_PENDING = 0
  STATUS_ACCEPTED = 1
  STATUS_REJECTED = 2
  
  N_('revise_status|1')
  N_('revise_status|2')
  N_('revise_status|0')
  
  belongs_to  :member
  belongs_to  :hot_spot
  belongs_to  :administrator, :class_name => 'Member', :foreign_key => 'admin_id' 
  
  validates_presence_of :suggestion
  validates_length_of :suggestion, :maximum=>600, :allow_nil=>true
end
