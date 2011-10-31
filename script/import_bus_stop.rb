require 'csv'

city = City.find ARGV[0]
admin = Member.find(1)

line = 1
CSV.open(ARGV[1], 'r') do |row|
  name, uid, line_name, position, fid, x, y, node_id, distance, line_fid, comp = row
  x = ((x.to_f - city.x0) * 100).round
  y = ((y.to_f - city.y0) * -100).round
  
  hot_spot = city.hot_spots.find :first, :conditions=>['name_zh_cn = ? and sqrt( pow( (x-?) * 0.007692, 2) + pow( (y-?) * 0.007692, 2)) < 100 and hot_spot_category_id = 11', name, x, y]
  traffic_line = city.traffic_lines.find_by_fid(line_fid)
  
  if traffic_line
    if hot_spot.nil?
      hot_spot = city.hot_spots.create(:name_zh_cn => name,
            :hot_spot_category_id=>11, :x=>x, :y=>y, :approved=>true, :creator=>admin)
    end
#    traffic_line.traffic_stops.create(:hot_spot_id => hot_spot.id)
    TrafficStop.connection.execute("INSERT INTO traffic_stops (`traffic_line_id`, `hot_spot_id`, `position`) VALUES(#{traffic_line.id}, #{hot_spot.id}, #{position})");
  else
    puts "ERROR: line #{line}: Unknown traffic line fid : #{line_fid}"
  end
  line = line + 1
end