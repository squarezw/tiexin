xml.result(:code=>@code) do  
  if @navi_star
    xml.navi_star (:release => @navi_star.release, :major => @navi_star.major, :minor => @navi_star.minor, :url => url_for(:controller=>'/download', :action=>'download', :platform => @navi_star.mobile_os.name,
        :release => @navi_star.release, :major => @navi_star.major,:minor => @navi_star.minor, :suffix => @navi_star.suffix))
  end
end