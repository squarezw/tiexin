# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'   

require 'gettext/utils' 

desc "Update pot/po files to match new version." 
task :updatepo do
  MY_APP_TEXT_DOMAIN = "xnavi" 
  MY_APP_VERSION     = "xnavi 0.0.1"    
  GetText::ActiveRecordParser.init(:activerecord_classes=>['ActiveRecord::Base'])
  GetText.update_pofiles(MY_APP_TEXT_DOMAIN, 
                         Dir.glob("{app,lib,themes}/**/*.{rb,rhtml,rjs,rxml,erb,builder}"), 
                         MY_APP_VERSION)
end

desc "Create mo-files for L10n" 
task :makemo do
  GetText.create_mofiles(true, "po", "locale")
end
