# Initializes theme support by extending some of the core Rails classes
require 'patches/actionview_ex'
require 'patches/actioncontroller_ex'
require 'patches/actionmailer_ex'
# require 'patches/routeset_ex'

# Add the tag helpers for rhtml and, optionally, liquid templates
require 'helpers/rhtml_theme_tags'
begin
   require 'helpers/liquid_theme_tags'   
rescue
   # I guess Liquid isn't being used...
   STDERR.puts "Liquid doesn't seem to be loaded... #{$!}"
end
