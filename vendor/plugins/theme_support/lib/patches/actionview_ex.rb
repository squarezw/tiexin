# Extending <tt>ActionView::Base</tt> to support rendering themes
#
module ActionView
   
   # Extending <tt>ActionView::Base</tt> to support rendering themes
   class Base
      alias_method :__render_file, :render_file

     def render_file(template_path, use_full_path = true, local_assigns = {})
        ["#{RAILS_ROOT}/themes/#{controller.current_theme}/views", # for normal views
          "#{RAILS_ROOT}/themes/#{controller.current_theme}" # for layouts
         ].each do |prefix|
          @finder.prepend_view_path(prefix)
        end
        __render_file(template_path, use_full_path, local_assigns)
      end
      # Overrides the default <tt>Base#render_file</tt> to allow theme-specific views
#      def render_file(template_path, use_full_path = true, local_assigns = {})
#         search_path = [
#            "../themes/#{controller.current_theme}/views",       # for components
#            "../../themes/#{controller.current_theme}/views",    # for normal views
#            "../../themes/#{controller.current_theme}",          # for layouts
#            "../../../themes/#{controller.current_theme}/views", # for mailer views
#            ".",                                                 # fallback
#            ".."                                                 # Mailer fallback
#         ]
#         
#         if use_full_path
#            search_path.each do |prefix|
#               theme_path = prefix +'/'+ template_path
#               begin
#                  template_extension = pick_template_extension(theme_path)
#
#                  # Prevent .rhtml (or any other template type) if force_liquid == true
#                  if force_liquid? and
#                     template_extension.to_s != 'liquid' and 
#                     prefix != '.'
#                     raise ThemeError.new("Template '#{template_path}' must be a liquid document")
#                  end
#                  
#                  local_assigns['active_theme'] = get_current_theme(local_assigns)
#               rescue ActionView::ActionViewError => err
#                  next
#               rescue ThemeError => err
#                  # Should it raise an exception, or just call 'next' and revert to
#                  # the default template?
#                  raise err
#               end
#               return __render_file(theme_path, use_full_path, local_assigns)
#            end
#            raise ActionViewError, "No rhtml, rxml, or delegate template found for #{template_path}"
#         else
#            __render_file(template_path, use_full_path, local_assigns)
#         end
#      end
      
   private
   
    def force_liquid?
      unless controller.nil?
        if controller.respond_to?('force_liquid_template')
          controller.force_liquid_template
        end
      else
        false
      end
    end

    def get_current_theme(local_assigns)
      unless controller.nil?
        if controller.respond_to?('current_theme')
          return controller.current_theme || false
        end
      end
      # Used with ActionMailers
      if local_assigns.include? :current_theme 
        return local_assigns.delete :current_theme
      end
    end
  end
end
