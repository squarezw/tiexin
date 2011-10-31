class SubscriptionMessageSentLog < ActiveRecord::Base
  untranslate_all 
  belongs_to :subscription_message
  belongs_to :member
  
  def increase_retry_times!
    self.retry_times += 1
  end
end
