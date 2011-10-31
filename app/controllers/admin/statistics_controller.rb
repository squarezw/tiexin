class Admin::StatisticsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  before_filter :parse_scope
  
  layout 'admin'
  
  ASSET_CLASSES = [Member, City, HotSpot, Area, Brand, Product, NaviPhoto, Comment, Event, Article, Post]
  
  def index
    @visit_count = NaviAccessLog.count :conditions => ['created_at between ? and ?', @start_time, @end_time]
    @unique_ip_count = NaviAccessLog.count_by_sql "select count(*) from (select distinct remote_ip from access_logs where created_at between '#{format_time_for_sql(@start_time)}' and '#{format_time_for_sql(@end_time)}') unique_ips"
    @success_count = NaviAccessLog.count :conditions=> ['(created_at between ? and ?) and response_status like ?', @start_time, @end_time, '2%']
    @mobile_count = NaviAccessLog.count :conditions=>['(created_at between ? and ?) and mobile = ?', @start_time, @end_time, true]
    @anonymous_count = NaviAccessLog.count :conditions=>['(created_at between ? and ?) and member_id is null', @start_time, @end_time]
    @robot_count = NaviAccessLog.count :conditions=>['(created_at between ? and ?) and from_robot = 1', @start_time, @end_time]
    @download_count=DownloadLog.count :conditions=>['created_at between ? and ?', @start_time, @end_time]
    @total_download_count = DownloadLog.count 
    top_actions
    top_user_agents
    top_browsers
    top_members
    top_ips
  end
  
  def assets
    @asset_stats = ASSET_CLASSES.collect { |clazz| [_(clazz.to_s.underscore.humanize.downcase), clazz.count ] }
  end
  
  def hot_spot_detail
    @cities = City.find :all
    counts = HotSpot.connection.select_all "select city_id, hot_spot_category_id, count(*) cnt from hot_spots group by city_id, hot_spot_category_id"
    @counts_map = {}
    counts.each { |row|
      @counts_map[[row['city_id'].to_i, row['hot_spot_category_id'].to_i] ] = row['cnt']
    }
  end
  
  def new_hot_spot_count
    parse_scope
    @cities = City.find :all
    @rows = HotSpotCategory.roots.collect do |cat|
      ids = cat.id_of_all_children_include_self.join(',')
      start_time = Date.today.beginning_of_week - 7.day
      end_time = Date.today.beginning_of_week - 1.day
      counts= HotSpot.connection.select_all "select city_id, count(*) cnt from hot_spots where hot_spot_category_id in (#{ids}) and created_at >= '#{@start_time.to_formatted_s(:db)}' and created_at <= '#{@end_time.to_formatted_s(:db)}' group by city_id"
      counts_by_city = {}
      counts.each { |row| counts_by_city[row['city_id'].to_i] = row['cnt'].to_i }
      [cat, counts_by_city]
    end    
  end
  
  private
  def parse_scope
    @end_time = Time.now
    scope = params[:scope] or :today
    case scope.to_s
    when 'today'
      @start_time = Date.today
    when 'yesterday'
      @start_time = Date.today.yesterday
      @end_time = Date.today
    when 'this_week'
      @start_time = Date.today.beginning_of_week
    when 'last_week'
      @start_time = Date.today.beginning_of_week - 7.day
      @end_time = Date.today.beginning_of_week - 1
    when 'this_month'
      @start_time = Date.today.beginning_of_month
    when 'last_month'
      @start_time = Date.today.last_month.beginning_of_month
      @end_time = Date.today.beginning_of_month - 1
    else
      @start_time = Date.today
    end
  end
  
  def format_time_for_sql(time)
    time.strftime '%Y-%m-%d %H:%M:%S'
  end
  
  def top_actions
    @top_actions = NaviAccessLog.connection.select_all "select controller, action, count(*) cnt from access_logs where created_at between '#{format_time_for_sql @start_time}' and '#{format_time_for_sql @end_time}' group by controller, action order by cnt desc limit 10"
  end
  
  def top_user_agents
    @top_user_agents = NaviAccessLog.connection.select_all "select user_agent, count(*) cnt from access_logs where mobile = 0 and created_at between '#{format_time_for_sql @start_time}' and '#{format_time_for_sql @end_time}' group by user_agent order by cnt desc limit 10"
  end
  
  def top_browsers
    @top_browsers = NaviAccessLog.connection.select_all "select browser, browser_version, count(*) cnt from access_logs where (from_robot <> 1 or from_robot is null) and browser is not null and created_at between '#{format_time_for_sql @start_time}' and '#{format_time_for_sql @end_time}' group by browser, browser_version order by cnt desc limit 10"
  end
  
  def top_members
    @top_members = NaviAccessLog.connection.select_all "select member_id, count(*) cnt from access_logs where created_at between '#{format_time_for_sql @start_time}' and '#{format_time_for_sql @end_time}' and member_id is not null group by member_id order by cnt desc limit 10"
  end

  def top_ips
    @top_ips = NaviAccessLog.connection.select_all "select remote_ip, count(*) cnt from access_logs where created_at between '#{format_time_for_sql @start_time}' and '#{format_time_for_sql @end_time}' group by remote_ip order by cnt desc limit 10"
  end
end
