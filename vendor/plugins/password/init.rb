require 'password'

ActiveRecord::Base.class_eval do
  include Imon::ActiveRecord::Password
end