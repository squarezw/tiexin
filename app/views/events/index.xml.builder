xml.result :code=>100 do
  @events.each do |event|
    attrs ={:id=>event.id, 
            :begin_date=>event.begin_date, 
            :end_date=>event.end_date, 
            :summary=>localized_description(event.summary)}
   attrs[:picture] = event.post.thumb.url if event.post
    xml.event truncate(localized_description(event.content), 300), attrs
  end
end

