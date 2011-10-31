(HotSpot.find :all, :conditions=>['creator_id = ? and name_zh_cn = ?', 59, '井']).each do |hot_spot|
  hot_spot.destroy
end