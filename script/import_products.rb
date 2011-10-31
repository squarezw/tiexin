require 'csv'
require 'fileutils'

city = City.find ARGV[0]
CSV.open (ARGV[1], 'r') do |row|
  hot_spot = HotSpot.find_by_ref_id row[0]
  unless hot_spot.nil?
    photo_file = File.new "product/#{row[1]}/#{row[4]}"
    hot_spot.products.create (:name_zh_cn => row[2], :introduction_zh_cn => row[3], :photo=>photo_file)
  end
end