module NearbyHotSpotsHelper
    SCOPES = [ ['200M', 0.2], ['500M', 0.5], ['1000M', 1], ['2000M', 2] ]
    
    def scope_selector(name,selected)
      html = "<select name=#{name}>"
      html << options_for_select(SCOPES, selected)
      html << '</select>'
      return html
    end
end
