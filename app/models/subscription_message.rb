class SubscriptionMessage < ActiveRecord::Base
  untranslate_all 
  belongs_to :subscription_topic
  belongs_to :content_object, :polymorphic => true
  has_many :subscription_message_sent_logs, :dependent=>:delete_all
  
  def publish
    return if self.sent
    while (receiver = first_unsent_member)
      publish_to receiver
    end
    while (receiver = first_retry_member)
      publish_to receiver 
    end
    self.update_attribute_with_validation_skipping :sent, true
    self.subscription_message_sent_logs.clear
  end 
  
  def publish_to(receiver)
    sent_log = self.subscription_message_sent_logs.find_or_create_by_member_id receiver.id
    return if sent_log.retry_times >= 3
    begin
      SubscriptionTopicMailer.send "deliver_#{self.subscription_topic.name}".to_sym, self.content_object, receiver unless receiver.mail.nil? or receiver.mail.empty?
      sent_log.sent = true
      sent_log.save!
	puts sleep(30)
    rescue Exception=> ex
      puts ex.to_s
      puts ex.backtrace.join("\n")
      sent_log.increase_retry_times
      sent_log.save!
    end
  end
  
  private 
  def unsent_member_count
    Member.count :conditions=>['confirmed = ? and not exists (select * from subscription_message_sent_logs l where l.subscription_message_id = ? and l.member_id = members.id)', true, self.id]
  end
  
  def unsent_members(per_page=20)
    Member.paginate :conditions=>['confirmed = ? and not exists (select * from subscription_message_sent_logs l where l.subscription_message_id = ? and l.member_id = members.id)', true, self.id], :order=>'id', :page=>page, :per_page=>per_page
  end
  
  def first_unsent_member
    Member.find :first, :conditions=>['confirmed = ? and not exists (select * from subscription_message_sent_logs l where l.subscription_message_id = ? and l.member_id = members.id)', true, self.id], :order=>'id'
  end

  def first_retry_member
    Member.find :first, 
                :select=>'members.*',
                :include=>:subscription_message_sent_logs,
                :conditions=>['confirmed = ? and sent = ? and retry_times < 3 and subscription_message_sent_logs.subscription_message_id = ?', true, false, self.id],
                 :order=>'retry_times, members.id'
  end

end
