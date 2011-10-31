require 'rubygems'
require 'mechanize'

@agent = Mechanize.new # { |obj| obj.log = Logger.new('mechanize.log') }  # 是否记录到日志中
@agent.user_agent_alias = 'Windows Mozilla'
ArchiverEncoding = 'utf-8'

def get_page(href,method='get')
	@agent.get(href)
end

# 编码转换, t 目标编码，s 源编码
def encoding(content,t='gbk//IGNORE',s='utf-8')
	Iconv.conv(t, s, content)
end

def import_daq_events(event_name,event_content,hot_spot_name,hot_spot_address,start_date,end_date,picture)
  unless DaqEvent.find_by_event_name(event_name)
    DaqEvent.create(:event_name => event_name,:event_content => event_content,
      :hot_spot_name => hot_spot_name, :hot_spot_address => hot_spot_address,
      :start_date => start_date,:end_date => end_date,:event_category_id => 1, :picture => picture)
  else
    puts "existed : #{event_name}"
  end
end

city_id = ARGV[0] #piao.com 的城市id 1北京，2上海
pg = ARGV[1] # 页码
city_id ||= 1
pg ||= 1

page = get_page("http://www.piao.com/index.php?app=search&cate_id=1210&city_id=#{city_id}&page=#{pg}")
#page.encoding = ArchiverEncoding
path = "event_pic"

page.search("div[@class=right_bg_borders]/div[@class=right_con_bor]").each_with_index do |sc,i|
  puts i
  event_link = sc.search("div[2]/span/a").attr("href")
  event_name = sc.search("div[2]/span/a").text
  pic = sc.search("div[@class=right_con_botimg]/a/img")
  src = pic.attr('src')
  filename = src.value.split("/").last
  puts src
  picture = "#{path}/#{filename}"
  begin
    @agent.get(src).save("public/images/#{picture}")
  rescue
    puts "don't save #{filename}"
    next
  end

  date = sc.search("div[@class=right_con_botfont]/ul/li[3]").text
  if date =~ /~/
    start_date = date.gsub(/.*：(.+?)~.*/i,'\1').gsub(" ","")
    end_date = date.gsub(/.*~(.+?)/i,'\1').gsub(" ","")
  else
    start_date = date.gsub(/.*：(.+?)/i,'\1').gsub(" ","")
    end_date = nil
  end
  
  puts "#{start_date} - #{end_date}"

  page2 = get_page("http://www.piao.com/#{event_link}")
  event_content = page2.search("div[@class=cont_right_cont]").to_html

  puts encoding(event_name)
  #puts event_content

  hot_spot_link = sc.search("div[2]/ul/li[2]/a").attr("href")
  hot_spot_name = sc.search("div[2]/ul/li[2]/a").text
  page2 = get_page("http://www.piao.com/#{hot_spot_link}")
  hot_spot_address = page2.search("div[@class=main_cen_font]/dl/dd[6]").inner_html
  hot_spot_address.gsub!(/(.+?)\<a.*/i,'\1')

#  puts hot_spot_name
#  puts hot_spot_address

  import_daq_events(event_name,event_content,hot_spot_name,hot_spot_address,start_date,end_date,picture)
end



