# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
#config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true
config.cache_store = :mem_cache_store

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.perform_deliveries = true
GOOGLE_MAP_KEY = 'ABQIAAAALe2Xbt1poJrkAsVsbSl-XRSCvrx8bO4mKkM2o4pkL1g0Ny3vPBTEy6Kxyzz1FBjrqQgCnDcF1LlIbA'
ActionMailer::Base.delivery_method = :sendmail

ActionController::Base.asset_host = "http://localhost:3000"
