xml.result :code=>100 do
  xml.tag :tag=>@tag do 
    @hot_spot_tags.each do |tag|
      xml.description tag.description, :member=>tag.member.nick_name
    end
  end
end