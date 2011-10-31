module AreasHelper
  def add_area_marker(page, area)
    page.call "add_area_to_map", area.center[0], area.center[1], options_for_area_marker(area)
  end
  
  def options_for_area_marker(area)
    { :area_id => area.id, 
      :area_height => area.height, 
      :area_width => area.width, 
      :tooltip=>h(localized_description(area, :name)), 
      :unique_id=>"mk_area_#{area.id}",
      :bubble_content => render(:partial=>'/areas/marker', :locals => { :area => area } )}     
  end
end
