module LayoutMapsHelper       
  def layoutable_type(layoutable)
    layoutable.class.to_s.underscore
  end                                  
  
  def layoutable_detail(layoutable)
      hot_spot_path(layoutable)
  end
  
  def options_for_layout_maps(layoutable)
    options = layoutable.layout_maps.collect  do |map|
      [h(localized_description(map, :name)), map.id]
    end
    options_for_select options
  end
  
  def first_none_empty_category
    @hot_spot_counts.empty? ? root_categories.first : (@hot_spot_counts.keys.sort{|cat1, cat2| cat1 <=> cat2 }).last
  end

  def hot_spot_categories_for_layout_maps_of(layoutable)
    ids = Position.connection.select_values "select distinct hot_spot_category_id from positions inner join hot_spots on positions.hot_spot_id = hot_spots.id inner join layout_maps on positions.layout_map_id = layout_maps.id where layout_maps.layoutable_type = '#{layoutable.class.to_s}' and layout_maps.layoutable_id = #{layoutable.id}"
    return HotSpotCategory.find ids
  end
end
