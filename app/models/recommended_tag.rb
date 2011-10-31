class RecommendedTag < ActiveRecord::Base
  validates_presence_of :tag
  validates_length_of :tag, :maximum=>80, :allow_nil=>true
  
  def self.effective_for_city(city, limit=10)
    # 原来用的:order => rand() 要改进
    return self.find(:all, :conditions=>["exists (select * from hot_spot_tags t join hot_spots h on (t.hot_spot_id = h.id) where h.city_id = ? and t.tag = recommended_tags.tag)", city.id], :limit=>limit)
  end
end
