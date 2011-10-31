#!/usr/bin/env /var/www/xnavi/script/runner
require 'csv'

city = City.find(ARGV[0].to_i)
CSV.open(ARGV[1], 'r') do |row|
  city.map_levels.create(:no=>row[0], :scale=>row[1], :row=>row[2], :column=>row[3])
end