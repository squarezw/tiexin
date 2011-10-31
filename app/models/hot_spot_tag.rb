class HotSpotTag < ActiveRecord::Base
  belongs_to :hot_spot
  belongs_to :member
 
  validates_presence_of :tag
  validates_length_of :tag, :within=>0..50
  
  def self.effective_tags_in_city(city, keyword, limit=10)
    HotSpotTag.connection.select_all(HotSpotTag.sanitize_sql(["select distinct tag from hot_spot_tags t, hot_spots h where t.hot_spot_id = h.id and h.city_id = ? and t.tag like ? limit ?", city.id, keyword, limit]))
  end
 
  def validate_on_create
   unless HotSpotTag.count(:id, :conditions => ['tag = ? and member_id = ? and hot_spot_id = ?', self.tag,self.member_id,self.hot_spot_id]).zero?
     errors.add(:tag, _('You had already add this "%{cc}" tag to this hot_spot.')%{:cc => self.tag})
   end
  end
  
  def self.counts_tags_hotspots(id = nil,limit = 10)
    self.find_by_sql(["select *,count(tag) as ct from hot_spot_tags where member_id = ? group by tag order by ct desc limit ?",id,limit])
  end
  
  def self.tag_descriptions(tag = nil, hot_spot_id = nil)
    self.find(:all,:conditions =>['tag = ? and hot_spot_id = ?', tag, hot_spot_id])
  end
  
  def self.recommend_for_tag(tag, expire_month)
    HotSpot.update_all({:recommend => true, :recommend_expire_at => Time.now.since(expire_month.month)}, ["id in (select hot_spot_id from hot_spot_tags where tag = ?)",tag])
  end

  def modifiable_to?(user)
    user and (user.is_admin or user == self.member or user.has_privilege(:modify_hot_spot))
  end
  
end
