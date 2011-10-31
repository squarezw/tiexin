class GiftOrderMailer < ActionMailer::Base
  def confirm(order)
    subject     _('Confirm of gift order')
    body        :order=>order
    recipients  order.member.mail
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end

end
