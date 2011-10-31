module SearchHelper
  SCOPES = [ ['200M', 0.2], ['500M', 0.5], ['1000M', 1], ['2000M', 2], ['5000M', 5] ]
  
  def scope_selector
    html = '<select name="scope" >'
    html << options_for_select(SCOPES, '0.2')
    html << '</select>'
    return html
  end
end
