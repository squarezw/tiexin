module DownloadHelper
  def url_for_navi_star(navi_star)
    url_for :controller=>'/download', :action=>'download', :platform => navi_star.mobile_os.name,
             :release => navi_star.release, :major => navi_star.major, :minor => navi_star.minor, :suffix => navi_star.suffix
  end
end
