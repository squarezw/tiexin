require 'csv'
require 'fileutils'

out = CSV.open(ARGV[2], 'w')
hot_spots = HotSpot.find :all, :conditions => ['id > ? and city_id = ? and hot_spot_category_id <> 11', ARGV[0], ARGV[1]]
i=0
hot_spots.each do |hot_spot|
  hot_spot.products.each do |pro|
    if pro.photo and pro.photo.exists?
      out << [pro.hot_spot_id, pro.id, pro.name_zh_cn, pro.introduction_zh_cn, pro.photo.filename]
      path = File.join('product', pro.id.to_s)
      FileUtils.mkdir_p path
      FileUtils.cp pro.photo.path, File.join(path, pro.photo.filename)
    end
  end
end

out.close
