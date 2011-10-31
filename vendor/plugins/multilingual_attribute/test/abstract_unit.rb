require 'test/unit'
require 'rubygems'
require_gem 'activerecord'
require_gem 'activesupport'
require 'active_record/fixtures'
require File.dirname(__FILE__) + '/../lib/multilingual_attribute'

ActiveRecord::Base.class_eval do
  include Imon::Acts::MultilingualAttribute
end                    
          
ActiveRecord::Base.send :include, Imon::Acts::MultilingualAttribute::InstanceMethods   

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
cs = ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])
puts "Using #{cs.config[:adapter]} adapter"
#load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = true
end
