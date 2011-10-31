require 'csv'

city = City.find ARGV[0]

CSV.open(ARGV[1], 'r') do |row|
  name, uid, begin_time, end_time, s, fid, company = row
  op_time_cn = ""
  op_time_en = ""
  unless begin_time.empty?
    op_time_cn << "首班时间：#{begin_time}。" 
    op_time_en << "Start time：#{begin_time}。"     
  end
  
  unless end_time.empty?
    op_time_cn << "末班时间：#{end_time}。" 
    op_time_en << "End time：#{end_time}。" 
  end
  
  if s.to_s == '1'
    op_time_cn << '夜班车。'
    op_time_en << 'Night bus.' 
  end
  
  city.traffic_lines.create(:name_zh_cn => name,
                            :line_type=>TrafficLine::TYPE_BUS,
                            :operation_time_zh_cn => op_time_cn,
                            :operation_time_en => op_time_en,
                            :fid => fid)
end