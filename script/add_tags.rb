admin = Member.find 1
#HotSpot.find_all_by_hot_spot_category_id(577).each do |hot_spot|
keyword1='%北京移动全球通%'
keyword2='%移动会员持卡%'
HotSpot.find :all, :conditions=>['introduction_zh_cn like ? or introduction_zh_cn like ?', keyword1, keyword2] do |hot_spot|
  hot_spot.hot_spot_tags.create :tag=>'北京移动特约商户', :member=>admin
end