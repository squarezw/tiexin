class HotSpotsMailer < ActionMailer::Base  
  def recommend(hot_spot, from, receiver, email, note)
    subject     _('Recommend of %{name}') % { :name => localized_description(hot_spot, :name) }
    body        :from => from,
                :receiver => receiver,
                :hot_spot => hot_spot,
                :note => note,
                :url => url_for(:host=>XNavi::HOST_NAME, :controller=>'hot_spots', :action=>'show', :id=>hot_spot.id)
    recipients  email
    from        XNavi::EMAIL_FROM
    sent_on     Time.now 
    content_type  'text/html; charset=utf-8'
  end
end
