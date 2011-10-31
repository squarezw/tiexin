xml.result(:code=>100) do 
  xml.hot_spot hot_spot_attributes(@hot_spot) do
    if @hot_spot.container
      xml.address h(localized_description(@hot_spot.container, :address)) + '-' + h(localized_description(@hot_spot, :address))
    else
      xml.address h(localized_description(@hot_spot, :address))
    end
    xml.phone_number @hot_spot.phone_number
    introduction = h(localized_description(@hot_spot, :introduction))
    if introduction.empty?
      introduction = @hot_spot.brand.intro if @hot_spot.brand
    end
    xml.home_page @hot_spot.effective_home_page
    xml.introduction introduction
    xml.price @hot_spot.price_memo, :level=>user_friendly_code(:price_level, @hot_spot.price_level)
    xml.parking_slot user_friendly_code(:parking_slot, @hot_spot.parking_slot)
    xml.operation_time localized_description(@hot_spot, :operation_time)
    if @hot_spot.brand
      xml.brand :id => @hot_spot.brand_id, :name => h(localized_description(@hot_spot.brand, :name))
    end
    if @hot_spot.is_traffic_stop? 
      xml.station(:type => @hot_spot.hot_spot_category.traffic_stop_type ) do 
        @hot_spot.traffic_lines.each do |line|
          xml.traffic_line(:id => line.id, :name => localized_description(line, :name)  )
        end
      end
    end
    lines = @hot_spot.access_traffic_lines
    lines = unique_traffic_lines lines, @current_lang
    xml.traffic_lines do 
      lines.each do |line|
        xml.traffic_line(:id => line.id, :name => localized_description(line, :name)  )      
      end
    end
    
    if (score_count = @hot_spot.score_count) > 0
      xml.score :price=>@hot_spot.price_score, 
                :quality=>@hot_spot.quality_score,
                :service=>@hot_spot.service_score,
                :environment=>@hot_spot.environment_score,
                :scores_count=>score_count
    end
    
    unless @hot_spot.hot_spot_tags.empty?
      xml.tags do 
        @hot_spot.count_tags_by_tag(nil).each { |tag|
          xml.tag tag.tag
        }
      end
    end
    
    xml.other_info(
      :photo_count => @hot_spot.photos.count,
      :comment_count => @hot_spot.comments.count,
      :product_count => @hot_spot.products.count,
      :inner_hot_spot_count => @hot_spot.hot_spots.count,
      :layout_maps_count => @hot_spot.layout_maps.count
    )
    
    map_block = @hot_spot.city.default_map_level_for_mobile.map_block_contains(@hot_spot.coordinate(true))
    xml.map_block(:level => map_block[:no], :x => map_block[:x], :y => map_block[:y],
                  :url=>url_for(:controller=>'map_blocks', :action=>'show', :city_id=>@hot_spot.city_id, :level=>map_block[:no], :x=>map_block[:x], :y=>map_block[:y]) )
    
    unless @hot_spot.photos.empty?
      photo = @hot_spot.random_photo
      xml.photo :url => photo.photo.mobile.url 
    end
  end
end