# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'gettext/rails'             
require 'accept_lang'

class ApplicationController < ActionController::Base                     
  LANGUAGE_MAP={'zh.*' => 'zh_cn', 'en.*'=>'en'}        
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_xnavi_session_id'    
  
  before_init_gettext :current_lang
  
  init_gettext 'xnavi'
  
  before_filter :for_blog, :for_mobile_user, :find_current_user, :find_current_city, :find_current_partner
  after_filter :clear_gettext_cache, :write_access_log

  protected
  def block_ddos
    if NaviAccessLog.ddos?(request.remote_ip,request.env['HTTP_USER_AGENT'])
      write_access_log
      redirect_to "/500"
    end
  end

  def for_blog
     if !request.subdomains.empty? and request.subdomains.is_a? Array
       subdomain2 = request.subdomains[1]
       if subdomain2 and subdomain2 == 'blog'
          unless ['blogs','pictures','theme','member_hot_spots','comments', 'fckeditor'].include? controller_name
            if controller_name == 'articles' and (action_name == 'new' or action_name == 'edit')
                redirect_to "http://#{XNavi::DOMAIN_NAME}#{request.request_uri}"
            end
          end
       end
     end
  end
  
  def find_current_city
    return true if @mobile_user
    if city_id = cookies[:city_id]
      @current_city=City.find(city_id)
      bind_city
    else      
      city=City.find(2)
      @current_city = IpSources.city_for_ip_address request.remote_ip, city
      bind_city
    end
  end  
  
  def find_current_user           
    return true if @mobile_user
    if user_id = session[:member_id]
      @current_user=Member.find(user_id)
    else
      @current_user=find_remembered_user
    end                   
    @current_user = nil if @current_user and @current_user.locked?
  end     
  
  def find_remembered_user
    if cookies[:remember_me]
      user_id, digest = cookies[:remember_me].split ':'
      current_user= Member.find(user_id.to_i)
      if current_user.digest == digest
        logged_in(current_user)
        return current_user
      end
    end    
    return nil
  end
  
  def detect_robot
    if NaviAccessLog.from_robot? request.env['HTTP_USER_AGENT']
      request.format = :robot
    end
    return true;
  end
    
  def authenticated
    if @mobile_user
      logger.info "Is mobile user. Authenticate with HTTP Basic Authentication"
      authenticate_or_request_with_http_basic do |username, password| 
        logger.info "http basic authentication: '#{username}', '#{password}'"
        @current_user = Member.login(username, password) 
      end
      return ! @current_user.nil?
    else
      return true if @current_user
      flash[:note] = _('Please login at first.')
      redirect_to :controller=>'/sessions', :action=>'new', :forward_to=>request.request_uri
      return false      
    end
  end
  
  def is_admin
    return true if @current_user and @current_user.is_admin
    flash[:note] = _('You have no privilege to do this operation.')
    redirect_to main_path
  end
  
  def for_mobile_user
#    request.env.each_pair { |key, value| logger.info "env['#{key}'] = '#{value}' "}
    logger.info "User Agent: #{request.env['HTTP_ACCEPT']}"
    if request.env['HTTP_USER_AGENT'] =~ /XNavi Mobile App/ or
       request.env['HTTP_USER_AGENT'] =~ /^Mobile\/(\d+)/
      @mobile_user = true
    elsif (request.subdomains[0] == 'mob' and request.subdomains[1] != 'blog') or 
          (request.env['HTTP_ACCEPT'] and request.env['HTTP_ACCEPT'].include? 'application/vnd.wap.xhtml+xml')
      request.format = :xhtmlmp
    end
  end        
  
  def current_user
    @current_user
  end                             
  
  def current_lang                  
    @current_lang= cookies[:lang] ||
                   AcceptLanguages.select(request.env['HTTP_ACCEPT_LANGUAGE'], LANGUAGE_MAP) ||
                   :zh_cn
    @current_lang=@current_lang.to_sym if @current_lang.is_a?(String)
    cookies[:lang]= @current_lang.to_s if cookies[:lang].to_s.empty? 
    logger.info "current_language: #{@current_lang}"
    GetText.locale=@current_lang.to_s
  end             
  
  def logged_in(user) 
    session[:member_id] = user.id
#    cookies[:user_id]= { :value=>user.id.to_s } 
#    Session.login(user, request, session)
  end
  
  def find_current_partner
    if session[:partner_id]
      @current_partner = Partner.find session[:partner_id]
    end
  end

  def partner_authenticated
    if @current_partner
      return true
    end
    redirect_to new_partner_session_path
    return false
  end
  
  def alert(msg)
    respond_to do |want|
      want.html do 
                  flash.now[:note] = msg
                  render :template=>'/alert.rhtml', :layout=>false
                end
      want.js do 
                  render :update do |page| page.alert(msg) end
              end

    end
  end     
  
  def show_form_error(page, object, id='form_error')
    page.replace_html id, object.errors.full_messages.join("\n")
  end
  
  def generate_captcha
    @captcha = Captcha.new(4)
    logger.info "captcha code = #{@captcha.code}"
    session[:captcha]=@captcha.code
  end    
  
  def captcha_code_correct?
    logger.info "session[:captcha] = #{session[:captha]}"
    session[:captcha] and session[:captcha] == params[:captcha_code].upcase
  end
  
  def error_xml(error)
    flash[:notice] = error
    render :template => '/error.rxml', :layout=>false
  end

  def current_is_admin?
    @current_user and @current_user.is_admin
  end
  
  def bind_city
    cookies[:city_id]={ :value=>@current_city.id.to_s,
                        :expires => 10.years.from_now } unless @mobile_user
  end
  
  def adjust_current_city(city)
    unless @current_city == city
      @current_city = city  
      bind_city
    end
    @current_city
  end
  
  def clear_gettext_cache
    GetText.clear_cache
  end
  
  def rescue_action_in_public(exception)
    logger.info 'rescue_action_in_public'
    case exception
    when ::ActionController::RoutingError, ::ActionController::UnknownAction, ActiveRecord::RecordNotFound then
      render :file=>File.join(RAILS_ROOT, 'public', '404.html'), :status => 404, :layout=>false 
    else
      render :file=>File.join(RAILS_ROOT, 'public', '500.html'), :status => 500, :layout=>false
      logger.info 'general exception'
      begin
        ErrorLog.create! :member_id=>(@current_user ? @current_user.id : nil),
                         :request_uri=>request.request_uri,
                         :http_headers=>hash_to_string(request.env),
                         :parameters=>hash_to_string(params),
                         :error_messages=>exception.message,
                         :stack_trace=>exception.backtrace.join("\n")
      rescue => ex
        logger.error ex.message
        logger.error ex.backtrace.join("\n")
      end
    end
  end
  
  def write_access_log
    access_log = NaviAccessLog.new :member=>@current_user, 
                     :mobile=>(@mobile_user or false),
                     :locale => @current_lang.to_s,
                     :remote_ip => request.remote_ip,
                     :controller => params[:controller],
                     :action => params[:action],
                     :method => request.method.to_s,
                     :user_agent => request.env['HTTP_USER_AGENT'],
                     :referer => request.env['HTTP_REFERER'],  
                     :request_uri => request.request_uri,
                     :response_status => response.headers['Status']  
    unless access_log.save
      logger.error access_log.errors.full_messages.join("\n")
    end
  end
  

  def find_hot_spot_category(root_id=nil,children_id=nil)
     id = (children_id.nil? || children_id.blank?)? (root_id.nil? || root_id.blank?)? nil: root_id : children_id
     if id and !id.empty?
         return HotSpotCategory.find(id)
     else
         return nil
     end
  end
  
  def class_for_name(name)
    name.camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
  end
  
  def is_from_person
    unless captcha_code_correct?
      flash.now[:note]= _('Invalid verification code.')   
      if request.xhr?
        render :tempatel=>'/alert.js.rjs', :layout=>false
      else
        render :action=>:new
      end
      return false
    end           
    return true
  end
  
  def parse_start_limit
      @start = params.has_key?(:start) ? params[:start].to_i : 0
      @limit = params.has_key?(:limit) ? params[:limit].to_i : 1000
      @start = 0 if @start < 0
      @limit = 1000 if @limit < 0 or @limit > 1000
      @page = (@start / @limit) + 1
      @per_page = @limit
  end
  
  def format_date(date)
    return '' if date.nil?
    return date.strftime('%Y-%m-%d') if date.respond_to?(:strftime)
    return date.to_formatted_s('%y-%m-%d') if date.respond_to?(:to_formatted_s)
    ''
  end        
  
  def format_time(time)
    time.nil? ? '' : time.strftime('%Y-%m-%d %H:%M')
  end
  
  def blog_root_url(blog)
    "http://#{blog.simple_name}.blog.#{XNavi::SITE_DOMAIN_NAME}"
  end  
  
  def hash_to_string(h)
    (h.keys.collect { |key| "#{key}=>'#{h[key]}'"}).join("\n")
  end
    
  def class_name_for_url(obj)
    clazz = obj.is_a?(Class) ? obj : obj.class
    clazz.to_s.underscore
  end
    
  N_('en')
  N_('zh_cn')
  N_('true')
  N_('false')
  N_('Sunday')
  N_('Monday')
  N_('Tuesday')
  N_('Wednesday')
  N_('Thursday')
  N_('Friday')
  N_('Saturday')
end

class Fixnum #:nodoc:
  XChar = Builder::XChar if ! defined?(XChar)

  # XML escaped version of chr
  def xchr
    n = XChar::CP1252[self] || self
    n = 42 unless XChar::VALID.find {|valid| 
      if valid.respond_to? 'include?'
        valid.include? n
      else
        valid == n
      end
    }
    XChar::PREDEFINED[n] or (n<128 ? n.chr : [n].pack('U'))  end
end
