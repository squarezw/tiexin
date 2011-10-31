require 'csv'

city = City.find ARGV[0].to_i
admin = Member.find_by_login_name('admin')

def parse_cat_table(file_name)
  line = 1
  table = {}
  CSV.open(file_name, 'r') do |row|
    l1, l2, l3, code = row[1], row[3], row[5], row[6]
    unless row[6].nil? or row[6].empty? or row[6] == '…'
      cat_name = [l3, l2, l1].find { |item| ! (item.nil? or item.empty?) }
      unless cat_name.nil? or cat_name.empty?
        cat = HotSpotCategory.find_by_name_zh_cn(cat_name)
        unless cat.nil? 
          table[code] = cat
        else
          puts "line #{line}: Can not find hot spot category #{cat_name}"
        end
      end
    end
    line = line + 1
  end
  table
end

cat_table = parse_cat_table(ARGV[1])

line = 1
unknown_codes = Set.new
CSV.open(ARGV[2], 'r').each do |row|
  name, cat_code, address, x, y = row[1], row[2], row[4], row[5], row[6]
  cat_code = '0X' + cat_code unless cat_code =~ /0X.*/
  category = cat_table[cat_code]
  unless category.nil?
    city.hot_spots.create(:name_zh_cn=>name, 
                          :hot_spot_category => category,
                          :address_zh_cn => address,
                          :x => (x.to_f - city.x0) * 100,
                          :y => (y.to_f - city.y0) * -100,
                          :creator=> admin )
  else
    puts "ERROR: line #{line}: Unknown category code #{cat_code}, name #{name}."
  end
  line = line+1
end

unknown_codes.each { |code| puts code }