class NaviAccessLog < ActiveRecord::Base
  untranslate_all 
  set_table_name 'access_logs'
  belongs_to :member

  before_save :figure_browser
  before_save :figure_from_robot
  
  def self.from_robot?(user_agent)
    ! (user_agent =~ /(googlebot)|(spider)|(crawler)|(yahoo)|(youdao)|(sosospide)(twiceler)/i).nil?
  end
  
  def figure_browser
    case self.user_agent
    when /Firefox\/([\d.]+)/
      self.browser = 'Firefox'
      self.browser_version = $1
    when /Safari/
      self.browser = 'Safari'
      self.user_agent =~ /Version\/([\d.]+)/
      self.browser_version = $1
    when /MSIE/
      self.browser = 'Internet Explorer'
      self.user_agent =~ /MSIE ([\d|.]+)/
      self.browser_version = $1
    when /Opera/
      self.browser = 'Opera'
      self.user_agent =~ /Opera\/([\d|.]+)/
      self.browser_version = $1
    else
      ''
    end
    return true
  end
  
  def figure_from_robot
    self.from_robot = NaviAccessLog.from_robot? self.user_agent
    return true
  end

  # 判断是否是ddos攻击,5秒内，同一IP不停刷新一页
  def self.ddos?(ip,user_agent)
    return false if from_robot?(user_agent)
    sql = "select count(*) from access_logs where TIMESTAMPDIFF(SECOND,created_at,NOW()) < 3 and id = (select id from access_logs where remote_ip = '#{ip}' order by id desc limit 1)"
    dd = NaviAccessLog.connection.select_value sql
    if dd.to_i > 0
      return true
    else
      return false
    end
  end
end