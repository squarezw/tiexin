class Campaign < ActiveRecord::Base
  TRIGGER_REGISTER = 1
  ALL_TRIGGERS = [TRIGGER_REGISTER]
  
  N_('campaign_trigger|1') # Register
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>100, :allow_nil=>true
  validates_presence_of :trigger
  validates_inclusion_of :trigger, :in=>ALL_TRIGGERS, :allow_nil=>true 
  validates_presence_of :expire_date
  validates_numericality_of :bonus_experience, :only_integer=>true, :greater_than_or_equal_to => 0, :allow_nil=>true, :message=>_('Must be zero or positive integer.')
  validates_numericality_of :bonus_credit, :only_integer=>true, :greater_than_or_equal_to => 0, :allow_nil=>true, :message=>_('Must be zero or positive integer.')
  
  def self.active_campaigns_for(trigger)
    self.find :all, :conditions=>['expire_date >= ? and campaigns.trigger = ?', Date.today, trigger], :order=>'created_at'
  end
  
  def validate
    if (self.bonus_experience.nil? or self.bonus_experience == 0) and 
       (self.bonus_credit.nil? or self.bonus_credit == 0)
      errors.add :bonus_experience, _('Some bonus, at least bonus experience, is required.')
    end
  end
  
  def modifiable?
    return ! expired?
  end
  
  def expired?
    return self.expire_date <= Date.today
  end
  
  def apply(member)
    member.score! :experience, self.bonus_experience if self.bonus_experience and self.bonus_experience > 0
    member.score! :credit, self.bonus_credit if self.bonus_credit and self.bonus_credit > 0
  end
end
