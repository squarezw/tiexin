require 'csv'
require 'fileutils'

out = CSV.open(ARGV[2], 'w')
hot_spots = HotSpot.find :all, :conditions => ['id > ? and city_id = ? and hot_spot_category_id <> 11', ARGV[0], ARGV[1]]
i=0
hot_spots.each do |hot_spot|
  hot_spot.photos.each do |photo|
    if photo.photo and photo.photo.exists?
      out << [hot_spot.id, photo.id, photo.subject, photo.photo.filename]
      path = File.join('photo', photo.id.to_s)
      FileUtils.mkdir_p path
      FileUtils.cp photo.photo.path, File.join(path, photo.photo.filename)
    end
  end
end

out.close
