DESTINATION_ID = 2
city_id = ARGV[0].to_i
case city_id
when 1 then
  Y0= 12728253.98
  X0= 5110764.45
when 2 then
  Y0= 13410777.44
  X0= 3748128.75
end

B0=Math::PI * (0.0 / 180.0)
L0=Math::PI * (0.0 / 180.0)
E0=0.081819190928906199466877879559801
E1=0.082094438036854130721083063414241
a= 6378137.0
b= 6356752.3142
K=((a**2)/b)/Math.sqrt(1+(E1*Math.cos(B0))**2)*Math.cos(B0)

def mercator_latlng(x1, y1)
  x = X0 - x1
  y = Y0 + y1
  latitude=0.5
  10.times do
    latitude= (Math::PI/2) - 2*Math.atan( Math.exp(-x/K) * Math.exp( (E0/2) * Math.log( (1-E0*Math.sin(latitude)) / ( 1+ E0*Math.sin(latitude)))))
  end
  longitude = y/K + L0

  latitude = 180.0 * (latitude / Math::PI) - 0.001991707265250
  longitude = 180.0 * (longitude / Math::PI) + 0.004630313144570
  return {:latitude => latitude, :longitude=> longitude}
end

conds = []
id_min = ARGV[1]
id_max = ARGV[2]
@hot_spots = HotSpot.find(:all, :conditions => ["id >= ? and id <= ? and city_id = ?",id_min, id_max, city_id])
for hot_spot in @hot_spots
  cond = mercator_latlng(hot_spot.y.to_i / 100,hot_spot.x.to_i / 100)
  puts "#{hot_spot.id}, #{cond[:latitude]}, #{cond[:longitude]}"
  hot_spot.update_attributes(:latitude => cond[:latitude], :longitude => cond[:longitude])
end