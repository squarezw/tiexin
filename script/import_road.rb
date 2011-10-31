require 'csv'
require 'coordinate'

road_nodes = {}

city = City.find ARGV[0].to_i

CSV.open(ARGV[2], 'r') do |row|
  id, x, y = row[0].to_i, row[1].to_f, row[2].to_f
  road_nodes[id] = city.coordinate_from_mercator(x, y)
#  puts "road_nodes[#{id}] = (#{road_nodes[id].to_s})"
end

puts "road segment count: #{road_nodes.size}"

CSV.open(ARGV[1], 'r') do |row|
  start_node, end_node, name = row[1].to_i, row[2].to_i, row[4]
  puts "(#{start_node}, #{end_node})"
  unless name.empty?
    road = city.roads.find_or_create_by_name_zh_cn name
    segment = road.road_segments.build 
    puts "from #{road_nodes[start_node]} to #{road_nodes[end_node]}"
    segment.start_coordinate= road_nodes[start_node]
    segment.end_coordinate= road_nodes[end_node]
    segment.save!
  end
end
