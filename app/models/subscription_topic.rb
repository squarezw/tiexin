class SubscriptionTopic < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true 
  has_many :subscription_messages, :dependent=>:delete_all
  
  def self.find_or_create_by_name(name, sent_all=true)
    topic = self.find_by_name name.to_s
    if topic.nil?
      topic = self.create! :name=>name.to_s, :sent_all=>sent_all
    end
    return topic
  end
end
