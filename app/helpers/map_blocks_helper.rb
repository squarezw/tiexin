module MapBlocksHelper
  def to_xml_for_map_block(xml, map_block, include_hot_spots = false, category_id = nil, options={})
    attrs ={:x => map_block[:x], 
            :y => map_block[:y], 
            :level=>map_block[:no], 
            :url=>url_for(:controller=>'map_blocks', :action=>'show', :city_id=>@current_city.id, :level=>map_block[:no], :x=>map_block[:x], :y=>map_block[:y])}
    attrs[:hot_spot_number] = @current_city.hot_spot_count_in_map_block(map_block, category_id) if @start == 0
    xml.map_block attrs do
      if include_hot_spots
        @current_city.hot_spots_in_map_block(map_block, "name_#{@current_lang}", category_id, options).each do |hot_spot|
          xml.hot_spot hot_spot_attributes(hot_spot)
        end
      end
    end
  end
end
