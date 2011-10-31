class HotSpotSweeper < ActionController::Caching::Sweeper
  observe HotSpot, HotSpotTag, ZoomLevel

  def after_create(obj)
    puts "after_create(#{obj})"
    if obj.is_a? HotSpotTag
      expire_summary_detail obj.hot_spot
    elsif obj.is_a? ZoomLevel
      expire_summary_detail obj.layout_map.layoutable if obj.layout_map.layoutable.is_a?(HotSpot)
    end
  end
  
  def after_save(obj)
    puts "after_save(#{obj})"
    if obj.is_a? HotSpotTag
      expire_summary_detail obj.hot_spot
    elsif obj.is_a? HotSpot
      expire_summary_detail obj
    end
  end
  
  def after_destroy(obj)
    puts "after_destroy(#{obj})"
    if obj.is_a? HotSpotTag
      expire_summary_detail obj.hot_spot
    elsif obj.is_a? HotSpot
      expire_summary_detail obj
    elsif obj.is_a? ZoomLevel
      expire_summary_detail obj.layout_map.layoutable if obj.layout_map.layoutable.is_a?(HotSpot)
    end
  end
  
  private
  def expire_summary_detail(hot_spot)
    puts "expire_summary_for #{hot_spot.id}"
#    expire_fragment :controller=>'hot_spots', :action=>'summary_detail', :id=>hot_spot.id
    puts "hot_spots/summary_detail/#{hot_spot.id}"
    expire_fragment "hot_spots/summary_detail/#{hot_spot.id}"
    expire_fragment "hot_spots/#{hot_spot.id}/marker"
  end
end