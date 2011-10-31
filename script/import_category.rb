require 'csv'

line=1
CSV.open(ARGV[0],'r') do |row|
  if row.empty? or row[0].nil? or row[0].empty?
    puts "WARN: line #{line}: empty, ignore."
  else
    parent = HotSpotCategory.find_by_name_zh_cn row[0]
    unless parent.nil?
      sub = parent.children.find_by_name_zh_cn row[1]
      if sub.nil?
        parent.children.create :name_zh_cn=>row[1] 
        puts "INFO: line #{line}: new category '#{row[1]}' created."
      else
        puts "WARN: line #{line}: category '#{row[1]}' of '#{row[0]}' already exists, ignore it."
      end
    else
      puts "ERROR: line #{line}:  unknown parent category '#{row[0]}'."
    end
  end
  
  line += 1
end