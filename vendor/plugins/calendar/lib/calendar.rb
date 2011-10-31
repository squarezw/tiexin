require 'gettext/rails'

module Imon
  module ActionView
    module Calendar
      include GetText::Rails
      
      bindtextdomain("calendar", :path=>File.join(RAILS_ROOT, 'vendor/plugins/calendar/locale'))

      _('Sun')
      _('Mon')
      _('Tue')
      _('Wed')
      _('Thu')
      _('Fri')
      _('Sat')

      _('Jan')
      _('Feb')
      _('Mar')
      _('Apr')
      _('May')
      _('Jun')
      _('Jul')
      _('Aug')
      _('Sep')
      _('Oct')
      _('Nov')
      _('Dec')  
      
      def calendar(id, options={}, configs={})
        configs = ({:close=>'true'}).merge(configs)
        if configs.empty?
          config_str = "{}"
        else
          config_str = (configs.keys.collect { |key| 
            if configs[key].is_a?(Array)
              v = (configs[key].collect { |item| "'#{item.to_s}'" }).join(',')
              v = "[#{v}]"
            else
              v = "'#{configs[key].to_s}'"
            end
            "#{key.to_s}: #{v}"}).join(',')
          config_str = "{#{config_str}}"
        end
        week_days=%Q/["#{_('Sun')}", "#{_('Mon')}", "#{_('Tue')}", "#{_('Wed')}", "#{_('Thu')}", "#{_('Fri')}", "#{_('Sat')}" ]/
        month_names= %Q/["#{_('Jan')}","#{_('Feb')}","#{_('Mar')}","#{_('Apr')}","#{_('May')}","#{_('Jun')}","#{_('Jul')}","#{_('Aug')}","#{_('Sep')}","#{_('Oct')}","#{_('Nov')}","#{_('Dec')}"]/   
        
        html= <<HTML
     <div id="#{id}" style="position:absolute; display:none; width:140px !important;"></div>

     <script language="javascript">
     var #{id};

     function show_#{id} (){                                       
        var link=$('#{options[:anchor_element]}');
        var pos=YAHOO.util.Dom.getXY(link);
        #{id}.show();
        YAHOO.util.Dom.setXY($('#{id}'), [pos[0]+link.offsetWidth, pos[1] - (link.offsetHeight/2) ]);
     }                                                                            

     function setDate_for_#{id} (type, args, obj) {
      var date = args[0][0];
     	$('#{options[:date_field]}').value=date[0] + "-" + date[1] + "-" + date[2];
      #{id}.hide();
     }

     function init_calendar_#{id}() {
     	#{id} = new YAHOO.widget.Calendar("#{id}_table","#{id}", #{config_str});
     	#{id}.Locale.LOCALE_WEEKDAYS=#{week_days};
     	#{id}.Locale.LOCALE_MONTHS=#{month_names}; 
     	#{id}.Locale.NAV_ARROW_LEFT="/images/callt.gif";
     	#{id}.Locale.NAV_ARROW_RIGHT="/images/calrt.gif";
      #{id}.selectEvent.subscribe(setDate_for_#{id}, #{id});
HTML
      html << "#{options[:customizer]} (#{id});\n" if options.has_key?(:customizer)
      html << <<HTML
      #{id}.render();
      #{id}.hide();
     }  

     </script>
HTML
     end # method calendar
    end # Calendar
  end # ActionView 
  
  module Util 
    module Calendar
      def self.parse_date(str, format='%Y-%m-%d')
        return nil if str.nil? or str.blank?
        begin
          return Date.strptime str, format
        rescue ArgumentError
          return nil
        end
      end
    end #Calendar
  end #Util
end #Imon  

#{id} .Config.Options.LOCALE_WEEKDAYS=#{week_days};
#{id} .Config.Options.LOCALE_MONTHS=#{month_names};