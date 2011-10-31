module PositionsHelper  
  def label(position)
    "#{h(localized_description(position.layout_map.layoutable, :name))} (#{h(localized_description(position.layout_map, :name))})"
  end
end
