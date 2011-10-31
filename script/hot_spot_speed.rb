hot_spots = HotSpot.find(:all, :conditions => ['creator_id = ? ', ARGV[0] ], :order => 'created_at' )

intervals=[]

hot_spot = hot_spots.shift

hot_spots.each do |h|
  puts h.created_at
  i = h.created_at - hot_spot.created_at
  unless i > 30.minute
    puts i
    intervals << i    
  end
  hot_spot = h
end

if intervals.size > 0
  sum = intervals.inject(0) { |sum, i| sum += i}
  puts sum / intervals.size
end
