class SubscriptionTopicMailer < ActionMailer::Base
  def bulletin(bulletin, receiver)
    return if receiver.mail.nil? or receiver.mail.empty?
    subject     bulletin.title
    body        :bulletin=>bulletin, :member=>receiver
    recipients  receiver.mail
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end

  def topic(topic, receiver)
    subject     topic.title
    body        :topic=>topic, :member=>receiver
    recipients  receiver.mail
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end
end
