module Admin::LayoutMapsHelper
  def layout_map_div_id(layout_map) 
    "layout_map_#{layout_map.id}"
  end
end
