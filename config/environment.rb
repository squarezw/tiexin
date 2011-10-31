# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

$KCODE='u'
require 'jcode'
require 'active_record'
#require 'gettext/rails'
require 'search_server_proxy'

Rails::Initializer.run do |config|
  config.gem 'gettext', :version=> '1.93.0'
  config.gem "newrelic_rpm"
#  memcache_params = {
#    :compression => false,
#    :debug => false,
#    :namespace => "xnavi_#{RAILS_ENV}",  
#    :readonly => false,
#    :urlencode => false 
#  }
  
#  memcache_servers = ['localhost:11211']
  
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  #Rotate log files
  config.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log", "daily") 
  
  config.action_controller.session_store = :active_record_store 
  
#  config.action_controller.session = { :session_key => "_xnavi_session",
#    :secret => "ASDKLSKDFJLAKWOIEL-3920FS-230LSFJSLFWELASKDFJ" ,
#    :session_domain => '.tiexin.com'
#}
  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  #  config.action_controller.session_store = :mem_cache_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  
  
  
  
#  cache_params = *([memcache_servers, memcache_params].flatten)
#  CACHE = MemCache.new *cache_params
#  ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge({ 'cache' => CACHE})
end

require 'will_paginate'
# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register "image/png", :image

# Include your application configuration below      

module XNavi
#  DOMAIN_NAME='localhost'   
  SITE_DOMAIN_NAME = 'tiexin.com'
  DOMAIN_NAME='www.tiexin.com'
  HOST_NAME='www.tiexin.com'         
  EMAIL_FROM='service@tiexin.com'
  ADMIN_EMAIL='tiexin@x-navi.cn'
  ICP_NO='沪ICP备10018130号'
  SUPPORT_LANGS= [:en, :zh_cn]
  PLATFORM="production"
  
  MAP_BLOCK_DIR=File.join RAILS_ROOT, 'public', 'images', 'map_blocks'
  IMAGE_PATH=File.join RAILS_ROOT, 'public', 'images'
  DOWNLOAD_PATH=File.join RAILS_ROOT, 'public', 'navistar'
  DOWNLOAD_URL_PREFIX='/navistar'
  MAP_BLOCKS_SEND_MODE = 'redirect' # 'redirect' | 'send_file'
  VERSION="2.6.2"
end

XNavi::SearchServerProxy.config.server_host= '127.0.0.1'
XNavi::SearchServerProxy.config.port= 12001



