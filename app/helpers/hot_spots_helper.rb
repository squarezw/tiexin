module HotSpotsHelper         
  def hot_spot_icon(hot_spot)
    cat = hot_spot.category_path.find { |cat| ! cat.icon.nil? }
    cat ? cat.icon.url : '/images/default_category.gif'
  end              
  
  def hot_spot_map_icon(hot_spot)
    cat = hot_spot.category_path.find { |cat| ! cat.map_icon.nil? }
    cat ? cat.map_icon.url : '/images/default_category.gif'
  end              
  
  def link_to_show_tag(t)
    link_to_function "#{h(t.tag)}(#{t.count})", "show_tag_description('#{escape_javascript(t.tag)}')" 
  end
  
  def most_frequent_tags_of_hot_spot(hot_spot, limit=3)
    (hot_spot.most_frequent_tags(limit).collect {|t| t.tag}).join(',')
  end

  def add_hot_spot_marker(page, hot_spot, options={})
    options = {:bubble_partial=>'/hot_spots/marker', :no_bubble=>false}.merge(options)
    unless options[:no_bubble]
      if options.has_key? :bubble_content 
        bubble_content = options[:bubble_content]
      else
        bubble_content = render :partial=>options[:bubble_partial], :locals=>{:hot_spot=>hot_spot}
      end
    else
      bubble_content = ''
    end
    page.call "add_hot_spot_to_map", hot_spot.x, hot_spot.y, 
        :hot_spot_id=>hot_spot.id, 
        :category_id => hot_spot.hot_spot_category_id, 
        :tooltip => h(localized_description(hot_spot, :name)), 
        :icon => hot_spot_map_icon(hot_spot), 
        :root_category_id => hot_spot.root_category.id,
        :bubble_content => bubble_content,
        :unique_id => "mk_hot_spot_#{hot_spot.id}"
  end
  
  def traffic_lines_pass_throuth(hot_spot)
    (hot_spot.traffic_lines.collect { |line| h(localized_description(line, :name))}).join(',')
  end
  
  def hot_spot_attributes(hot_spot)
    attrs = {:id => hot_spot.id, 
             :name => localized_description(hot_spot, :name), 
             :category_id => hot_spot.hot_spot_category_id, 
             :root_category_id => hot_spot.hot_spot_category.root.id,
             :category_name=>localized_description(hot_spot.hot_spot_category, :name),
             :layout_maps_count=>hot_spot.layout_maps.count,
             :address=>localized_description(hot_spot, :address)
            }
    coordinate = hot_spot.coordinate(true)
    unless coordinate.nil?
      attrs.merge! :x => coordinate.x, :y=> coordinate.y 
    end
    if hot_spot.container
      attrs[:name]= attrs[:name] + "(#{localized_description(hot_spot.container, :name)})"
    end
    attrs
  end
  
  def picture_for_hot_spot(hot_spot)
    photo = hot_spot.random_photo
    return photo.photo.small_thumb unless photo.nil?
    return hot_spot.brand.pic.small if hot_spot.brand and hot_spot.brand.pic
    hot_spot.hot_spot_category.safe_big_icon
  end
  
  def large_picture_tag_for_hot_spot(hot_spot)
    photo = hot_spot.random_photo
    alt = h(localized_description(hot_spot, :name))
    return image_tag(photo.photo.thumb.url, :alt=>alt) unless photo.nil?
    return image_tag(hot_spot.brand.pic.mobile.url, :alt=>alt) if hot_spot.brand and hot_spot.brand.pic
    image_tag hot_spot.hot_spot_category.safe_big_icon.url, :alt=>alt unless hot_spot.hot_spot_category.safe_big_icon.nil?
    image_tag 'nopic.jpg', :alt=>alt
  end
  
  
  def picture_tag_for_hot_spot(hot_spot)
    photo = hot_spot.random_photo
    return image_tag(photo.photo.thumb.url, :alt=>photo.subject) unless photo.nil?
    return image_tag(hot_spot.brand.pic.url, :alt=>h(localized_description(hot_spot, :name))) if hot_spot.brand and hot_spot.brand.pic
    image_tag hot_spot.hot_spot_category.safe_big_icon.url, :alt=>h(localized_description(hot_spot, :name)) unless hot_spot.hot_spot_category.safe_big_icon.nil?
    image_tag 'nopic.jpg'
  end

  def small_picture_tag_for_hot_spot(hot_spot)
    pic = small_picture_for_hot_spot(hot_spot)
    unless pic.nil?
      return image_tag(pic.url, :alt => "#{h(localized_description(hot_spot, :name))}_#{XNavi::SITE_DOMAIN_NAME}")
    else
      return 'nopic.jpg'
    end
  end

  def small_picture_for_hot_spot(hot_spot)
    photo = hot_spot.random_photo
    return photo.photo.small_thumb unless photo.nil?
    return hot_spot.brand.pic.small if hot_spot.brand and hot_spot.brand.pic
    return hot_spot.hot_spot_category.safe_big_icon unless hot_spot.hot_spot_category.safe_big_icon.nil?
    return nil
  end
  
  def unique_traffic_lines(lines, language)
    result = []
    line_nos = []
    lines.each do |line|
      name = line.attributes["name_#{language}"]
      if name =~ /(.+)(\(.+\))$/
        line_no = $1
        unless line_nos.include?(line_no)
          result << line
          line_nos << line_no
        end
      else
        result << line
      end
    end
    return result.sort { |line1, line2| localized_description(line1, :name) <=> localized_description(line2, :name)}
  end
  
  def strip_branch_name(hot_spot)
    return h(localized_description(hot_spot, :name)) unless @current_lang == 'zh_cn'
    name = hot_spot.name.zh_cn
    logger.info "name = #{name}"
    if name =~ /(\(.*店\))/
      logger.info "matched"
      h(name.delete($1))
    else
      logger.info "unmatched"
      h(name)
    end
  end

  def effective_hot_spot_introduction(hot_spot)
    intro = h(localized_description(hot_spot, :introduction)) 
    if intro.blank? and hot_spot.brand
          intro = h(hot_spot.brand.intro)
  	end
  	return intro
  end
  
  def inner_hot_spots_for_show(container, limit=6)
    container.hot_spots.find :all, :order=>'(owner_id is null), updated_at desc', :limit=>limit
  end

  def add_hot_spot_gmarker(page, hot_spot, options={})
    options = {:draggable=>true}.merge(options)
    page.call 'add_and_show_model_marker',
             page.literal('map'),
             { :id=> hot_spot.id,
               :latitude=> hot_spot.latitude,
               :longitude=> hot_spot.longitude,
               :label=> hot_spot.name_zh_cn,
               :identity=> model_identity(hot_spot),
               :type_name=>'hot_spot',
               :inforWindowContent => render(:partial=>'/hot_spots/marker', :locals=>{:hot_spot=>hot_spot}) },
             options
  end
end
