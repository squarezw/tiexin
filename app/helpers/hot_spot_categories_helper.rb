module HotSpotCategoriesHelper
  def category_path_str(category, as_link = false)
    categories = category.ancestors.reverse
    categories << category
    if as_link
      (categories.collect { |cat| link_to h(localized_description(cat, :name)), city_hot_spot_category_path(@current_city, cat) }).join(' > ')
    else
      (categories.collect { |cat| h(localized_description(cat, :name)) }).join(' > ')
    end
  end
  
  def node_id(category)
    "cat_label_#{category.id}"
  end
  
  def safe_icon(category)
    cat_name = h(localized_description(category, :name))
    category.icon ? image_tag(category.icon.url, :size=>'25x25', :alt=>cat_name) : image_tag('default_category.gif', :size=>'19x19', :alt=>cat_name)
  end    
  
  def safe_map_icon(category)
    category.map_icon ? image_tag(category.map_icon.url, :size=>'25x33') : image_tag('default_category.gif', :size=>'19x19')
  end      

  def safe_big_icon(category)
    category.big_icon ? image_tag(category.big_icon.url, :size=>'64x64') : image_tag('default_category.gif', :size=>'64x64')
  end      
  
  def to_xml(xml, category, level)
    xml.hot_spot_category(:id => category.id, :name=>localized_description(category, :name), :level => level ) do 
      category.children.each do |category|
        to_xml(xml, category, level+1)
      end
    end
  end
  
  def start_point
    if @hot_spots and !@hot_spots.empty?
      hot_spot = @hot_spots[0]
      "[#{hot_spot.coordinate.x}, #{hot_spot.coordinate.y}]"      
    else
      "[#{@current_city.start_point.x}, #{@current_city.start_point.y}]"
    end
  end
end
