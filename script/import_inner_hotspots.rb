require 'csv'

city = City.find ARGV[0]
CSV.open(ARGV[1], 'r') do |row|
  container_cat = HotSpotCategory.find_by_name_zh_cn row[1]
  container = HotSpot.find_by_name_zh_cn_and_hot_spot_category_id row[0], container_cat.id
  
  inner_hs_cat = HotSpotCategory.find_by_name_zh_cn row[3]
  inner_hs = HotSpot.find_by_name_zh_cn_and_hot_spot_category_id row[2], inner_hs_cat.id
  
  if container and inner_hs and inner_hs.container.nil?
    inner_hs.update_attributes! :x=>container.x, :y=>container.y, :container_id=>container.id
  end
end