xml.result :code => 100 do
  unless @category_ids.nil? or @category_ids.empty?
    @category_ids.each do |id|
      xml.hot_spot_category_id :id => id 
    end
  end
  @layout_map.positions.each do |position|
    hot_spot = position.hot_spot
    xml.hot_spot :id => position.hot_spot_id, :name => h(localized_description(position.hot_spot, :name)), :category_id => position.hot_spot.hot_spot_category_id, :x => position.x, :y => position.y do 
      xml.address localized_description(position.hot_spot, :address)
      introduction = h(localized_description(hot_spot, :introduction))
      if introduction.empty?
        introduction = hot_spot.brand.intro if hot_spot.brand
      end
      xml.introduction introduction
    end
  end 
end