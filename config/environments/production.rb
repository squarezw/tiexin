# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false 
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
config.action_controller.asset_host                  = "http://www.tiexin.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = :smtp

config.action_mailer.smtp_settings = {
  :address => 'smtp.xinnetvip.com',
  :domain => 'tiexin.com',
  :authentication => :login,
  :user_name => 'service@tiexin.com',
  :password => 'tx123456'
}

ActionController::Base.cache_store =
                            :file_store, %W( #{RAILS_ROOT}/tmp/cache )
                          
GOOGLE_MAP_KEY = 'ABQIAAAA2sX6ncC7H0agu89s-b0JexR0rpc3hkdGF2n449yEhG3KNPxuGRQRV3732JDu3E8opo-EZQQXrIJqrA'