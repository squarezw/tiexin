class Promotion < Event
  N_('promotion')
  
  def self.cur_hot_spot(hot_spot_id,current_city,limit='1')
    return Promotion.find(:all,:conditions => ["vendor_type = 'HotSpot' and vendor_id = ? and end_date >= ?",hot_spot_id,Time.now.to_date],:limit=>limit)
  end
  
  def self.cur_hot_spot_category(hot_spot_category,current_city,limit='1')
    cat_ids = hot_spot_category.id_of_all_children_include_self
    
    conditions = ["( (vendor_type = 'HotSpot' and vendor_id in (select id from hot_spots h where h.city_Id = ? and h.hot_spot_category_id in (?)))"]
    conditions << current_city.id << cat_ids
    conditions.first << "or ( (events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?) "
    conditions << current_city.id
    conditions.first << " and vendor_type = 'Brand' and vendor_id in (Select id from brands where hot_spot_category_id in (?))) ) ) and end_date >= ?"
    conditions << cat_ids << Time.now.to_date
    return Promotion.find(:all,:conditions =>conditions,:limit=>limit)
  end
  
  def self.rand_promotion(current_city,limit='1')
       # 原来用的:order => rand() 要改进
       return Promotion.find(:first,  :conditions => ["(events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?)) and end_date >= ?", current_city.id, Time.now.to_date], :limit=>limit)
  end
  
  
  def before_save
      if self.vendor.is_a? HotSpot
        self.cities << self.vendor.city
        self.allcity = false
      else
        self.allcity = (self.cities.nil? or self.cities.empty?)  
      end
      self.event_category_id = 6
      return true
  end
  
  def modifiable_to?(user)
    user and (user.has_privilege(:manage_events) or self.vendor.owner_id == user.id)
  end
  
end
