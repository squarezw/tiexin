class MemberMailer < ActionMailer::Base
  def confirm_registration(member)
    return unless member.mail
    subject     _('Confirm Registration of X-Navi')
    body        :member => member,
                :confirm_url=> url_for(:host=>XNavi::HOST_NAME, 
                                       :controller=>'members', 
                                       :action=>:confirm_registration, 
                                       :id=>member,  
                                       :confirm_code=>member.confirm_code)
    recipients  member.mail
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end
  
  def reset_password(user, new_password)
    return unless user.mail
    subject      _('Password is resetted.')
    recipients   user.mail
    from         XNavi::EMAIL_FROM
    sent_on      Time.now
    body         :member => user,
                 :password => new_password 
  end
  
  def invite_friend(receiver, invitation, note, inviter)
      return unless invitation.mail
      subject     _('Your friend %{name} invite you to join X-Navi.') % { :name => inviter }
      body        :inviter => inviter,
                  :receiver => receiver,
                  :note => note,
                  :url => url_for(:host=>XNavi::HOST_NAME, :controller=>'members', :action=>'new', :invitation_id=>invitation.id)
      recipients  invitation.mail
      from        XNavi::EMAIL_FROM
      sent_on     Time.now 
      content_type  'text/html; charset=utf-8'
  end

  def confirm_mail_edit(member)
    return unless member.mail_confirm
    subject     _('Confirm edit mail of X-Navi')
    body        :member => member,
                :confirm_url=> url_for(:host=>XNavi::HOST_NAME, 
                                       :controller=>'members', 
                                       :action=>:confirm_mail_edit, 
                                       :id=>member,  
                                       :mail_confirm_code=>member.mail_confirm_code)
    recipients  member.mail_confirm
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end  
end
