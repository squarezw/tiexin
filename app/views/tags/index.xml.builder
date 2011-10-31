xml.result(:code=>'100') do
    @hot_spot_tags.each do |tag|
      xml.tag(:tag => tag.tag) do 
        HotSpotTag.tag_descriptions(tag.tag,tag.hot_spot_id).each do |t|
          xml.description(t.description,:member => t.member.nick_name)
        end
      end
    end    
end
