class DownloadController < ApplicationController
  before_filter :find_current_city, :except=>['mobile', 'download']
  before_filter :write_head, :only=>:mobile
  layout 'mobile', :only=>:mobile
  
  def mobile
    figure_model_and_os
    @mobile_os = MobileOs.find_by_name @mobile_os_name unless @mobile_os_name.nil?
    @mobile_brands = MobileBrand.find(:all)
    @navi_stars = NaviStar.find :all
  end
  
  def select_model
      mobile_brand = MobileBrand.find(params["mobile_brand_id"].to_i)
      @mobile_models = mobile_brand.mobile_models
  end
  
  def download
    version = "#{params[:release]}.#{params[:major]}.#{params[:minor]}"
    file_name = "NaviStar_#{params[:platform]}_#{version}.#{params[:suffix]}"
    path = File.join XNavi::DOWNLOAD_PATH, file_name
    logger.info "path = #{path}"
    if File.exist? path
      DownloadLog.create! :platform=>params[:platform], :version=>version
      redirect_to "#{XNavi::DOWNLOAD_URL_PREFIX}/#{file_name}"
    else
      render :file=>File.join(RAILS_ROOT, 'public', '404.html'), :status=>'404', :layout=>false
    end
  end
  
  private
  def figure_model_and_os
    user_agent = request.env['HTTP_USER_AGENT']
    case user_agent
    when /dopod\s(.*)_.*/
      @mobile_model_name = "Dopod #{$1}"
      @mobile_os_name = 'WindowsMobile'
    when /SymbianOS.*Series60\/3/
      @mobile_os_name = 'Symbian_S60_3rd'
      @mobile_model_name = "Nokia #{$1}" if user_agent =~ /Nokia([\w]+)[\/-]/
    end
  end
  
  def write_head
    request.env.each_pair do |key, value|
      logger.info "#{key}='#{value}'"
    end
  end
end
