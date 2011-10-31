class HotSpotAccessLog < ActiveRecord::Base
  belongs_to :member
  belongs_to :hot_spot
  
  untranslate_all
  
  def self.member_recent_access_hot_spots(member, city, limit=5)
    rows = self.connection.select_all "select hot_spot_id, max(l.created_at) t from hot_spot_access_logs l, hot_spots h where l.hot_spot_id = h.id and l.member_id = #{member.id} and h.city_id = #{city.id} group by hot_spot_id order by t desc limit #{limit}"
    rows.collect { |row| HotSpot.find row['hot_spot_id']}
  end
end
