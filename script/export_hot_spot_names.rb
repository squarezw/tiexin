(HotSpot.find :all).each  { |hot_spot|
  puts "#{hot_spot.id}|#{hot_spot.name.zh_cn}|#{hot_spot.city_id}"
}