require 'csv'
require 'fileutils'

city = City.find ARGV[0]
admin = Member.find 1
CSV.open (ARGV[1], 'r') do |row|
  hot_spot = HotSpot.find_by_ref_id row[0]
  unless hot_spot.nil?
    photo_file = File.new "photo/#{row[1]}/#{row[3]}"
    hot_spot.photos.create (:subject => row[2], :photo=>photo_file, :owner=>hot_spot, :uploader=> admin)
  end
end