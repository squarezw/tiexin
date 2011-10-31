class OwnerApplication < ActiveRecord::Base
  STATUS_PENDING=0
  STATUS_APPROVED=1
  STATUS_DISAPPROVED=2
  
  N_('owner_application_status|0')
  N_('owner_application_status|1')
  N_('owner_application_status|2')
  
  belongs_to :target, :polymorphic => true
  belongs_to :member
  belongs_to :admin, :class_name=>'Member', :foreign_key => 'admin_id'  
  
  untranslate :target, :target_type
  
  def approved?
    self.status == STATUS_APPROVED
  end
  
  def pending?
    self.status = STATUS_PENDING
  end
end
