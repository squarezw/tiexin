require 'csv'
puts ARGV[0]
puts ARGV[1]

category = HotSpotCategory.find ARGV[1].to_i
cat_ids = category.id_of_all_children_include_self

out = CSV.open(ARGV[2] + ".csv", 'w')
hot_spots = HotSpot.find :all, :conditions => ["city_id = ? and hot_spot_category_id in (#{cat_ids.join(',')})", ARGV[0]], :order=>'hot_spot_category_id'
#hot_spots = HotSpot.find :all, :conditions => ["city_id = ?", ARGV[0]], :order=>'hot_spot_category_id'
i=0
hot_spots.each do |hot_spot|
  out << [hot_spot.id, hot_spot.name_zh_cn, hot_spot.hot_spot_category.name_zh_cn, hot_spot.address_zh_cn, hot_spot.phone_number, hot_spot.introduction.zh_cn, hot_spot.price_memo, hot_spot.parking_slot, hot_spot.operation_time_zh_cn, hot_spot.home_page]
  i+=1
  puts i if i % 100 == 0
end

out.close
