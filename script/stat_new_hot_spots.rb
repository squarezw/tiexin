City.find(:all).each do |city|
  puts "#{city.name.zh_cn}:"
  HotSpotCategory.roots.each do |cat|
    ids = cat.id_of_all_children_include_self.join(',')
    start_time = Time.today.beginning_of_week - 7.day
    end_time = Time.today.beginning_of_week - 1.day
    count = HotSpot.count :conditions=>["city_id = ? and id in (#{ids}) and created_at >= ? and created_at <= ? ", city.id, start_time.to_formatted_s(:db), end_time.to_formatted_s(:db)]
    puts "#{cat.name.zh_cn}: #{count}"
  end
end

City.find(:all).each do |city|
  puts "#{city.name.zh_cn}:"
  HotSpotCategory.roots.each do |cat|
    ids = cat.id_of_all_children_include_self.join(',')
    puts "city_id = #{city.id} and id in (#{ids}) and exists(select * from navi_photos where owner_type = 'HotSpot' and navi_photos.owner_id = hot_spots.id) "
    count = HotSpot.count :conditions=>["city_id = ? and id in (#{ids}) and exists(select * from navi_photos where owner_type = 'HotSpot' and navi_photos.owner_id = hot_spots.id) ", city.id]
    puts "#{cat.name.zh_cn}: #{count}"
  end
end