require 'csv'

city = City.find ARGV[0]
admin = Member.find 1
CSV.open(ARGV[1]+".csv", 'r') {|row|
  cat = HotSpotCategory.find_by_name_zh_cn row[1]
  city.hot_spots.create(:name_zh_cn => row[0], 
                        :hot_spot_category => cat,
                        :address_zh_cn=> row[2], 
                        :x => row[3], 
                        :y => row[4], 
                        :phone_number => row[5], 
                        :introduction_zh_cn => row[6], 
                        :price_level => row[7], 
                        :price_memo => row[8], 
                        :parking_slot => row[9],
                        :operation_time_zh_cn => row[11], 
                        :home_page => row[12],
                        :ref_id => row[13],
                        :creator => admin)
  puts row[13]
}

CSV.open(ARGV[1]+'_inner_hs.csv', 'r') { |row|
  container = HotSpot.find_by_ref_id row[0]
  inner = HotSpot.find_by_ref_id row[1]
  inner.update_attributes! :x=>container.x, :y=>container.y, :container_id => container.id
  
}