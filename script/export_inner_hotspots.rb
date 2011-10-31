require 'csv'

out = CSV.open ARGV[1], 'w'

hot_spots = HotSpot.find :all, :conditions => ['container_id is not null and city_id = ?', ARGV[0]] 

hot_spots.each  do |h|
  out << [h.container.name_zh_cn, h.container.hot_spot_category.name_zh_cn, h.name_zh_cn,h.hot_spot_category.name_zh_cn]
end