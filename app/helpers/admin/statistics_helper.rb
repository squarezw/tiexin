module Admin::StatisticsHelper
  def figure_browser(user_agent)
    case user_agent
    when /Firefox\/([\d.]+)/
      "Firefox/#{$1}"  
    when /Safari/
      user_agent =~ /Version\/([\d|.]+)/
      "Safari/#{$1}"
    else
      ''
    end
  end
end
