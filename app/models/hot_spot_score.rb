class HotSpotScore < ActiveRecord::Base
  PERIOD_RATE = 30
  SCORE_TYPE = [ [_('Score'),'score'],[_('Quality'),'quality_score'],[_('Service'),'service_score'],[_('Environment'),'environment_score'],[_('Price'),'price_score'] ]
  
  QUALITY_LEVEL_VERY_POOL = 0
  QUALITY_LEVEL_POOL = 1
  QUALITY_LEVEL_NORMAL = 2
  QUALITY_LEVEL_GOOD = 3
  QUALITY_LEVEL_EXCEPTIONAL = 4
  QUALITY_LEVELS = [QUALITY_LEVEL_EXCEPTIONAL, QUALITY_LEVEL_GOOD, QUALITY_LEVEL_NORMAL, QUALITY_LEVEL_POOL, QUALITY_LEVEL_VERY_POOL]
  N_("quality_level|0")
  N_("quality_level|1")
  N_("quality_level|2")
  N_("quality_level|3")
  N_("quality_level|4")
  
  SERVICE_LEVEL_VERY_BAD = 0
  SERVICE_LEVEL_BAD = 1
  SERVICE_LEVEL_NORMAL = 2
  SERVICE_LEVEL_GOOD = 3
  SERVICE_LEVEL_EXCEPTIONAL = 4
  SERVICE_LEVELS = [SERVICE_LEVEL_EXCEPTIONAL, SERVICE_LEVEL_GOOD, SERVICE_LEVEL_NORMAL, SERVICE_LEVEL_BAD, SERVICE_LEVEL_VERY_BAD]
  N_("service_level|0")
  N_("service_level|1")
  N_("service_level|2")
  N_("service_level|3")
  N_("service_level|4")

  ENVIRONMENT_LEVEL_VERY_BAD = 0
  ENVIRONMENT_LEVEL_BAD = 1
  ENVIRONMENT_LEVEL_NORMAL = 2
  ENVIRONMENT_LEVEL_GOOD = 3
  ENVIRONMENT_LEVEL_EXCEPTIONAL = 4
  ENVIRONMENT_LEVELS = [ENVIRONMENT_LEVEL_EXCEPTIONAL, ENVIRONMENT_LEVEL_GOOD, ENVIRONMENT_LEVEL_NORMAL, ENVIRONMENT_LEVEL_BAD, ENVIRONMENT_LEVEL_VERY_BAD]
  N_("environment_level|0")
  N_("environment_level|1")
  N_("environment_level|2")
  N_("environment_level|3")
  N_("environment_level|4")

  PRICE_LEVEL_VERY_EXPENSIVE = 0
  PRICE_LEVEL_EXPENSIVE = 1
  PRICE_LEVEL_NORMAL = 2
  PRICE_LEVEL_CHEAP = 3
  PRICE_LEVEL_VERY_CHEAP = 4
  PRICE_LEVELS = [PRICE_LEVEL_VERY_CHEAP, PRICE_LEVEL_CHEAP, PRICE_LEVEL_NORMAL, PRICE_LEVEL_EXPENSIVE,  PRICE_LEVEL_VERY_EXPENSIVE]
  N_("price_level|0")
  N_("price_level|1")
  N_("price_level|2")
  N_("price_level|3")
  N_("price_level|4")
  
  belongs_to :hot_spot
  belongs_to :member

  def after_save
    quality_score = HotSpotScore.avg("quality",self.hot_spot_id)
    service_score = HotSpotScore.avg("service",self.hot_spot_id)
    environment_score = HotSpotScore.avg("environment",self.hot_spot_id)
    price_score = HotSpotScore.avg("price",self.hot_spot_id)
    
    score = quality_score + service_score + environment_score + price_score

    score_count = HotSpotScore.count :conditions => ['hot_spot_id = ?',self.hot_spot_id]

    HotSpot.update(self.hot_spot_id,:quality_score =>quality_score,:service_score => service_score, :environment_score => environment_score,:price_score => price_score,:score => score, :score_count => score_count)    
  end
  
  def validate_on_create
   unless count_in_30day_rate.zero?
     errors.add(:hot_spot_id, _('You can not repeat rate'))
   end
  end
  
  def self.ownership_score_sweep!(hot_spot_id,member_id)
    delete_all ["hot_spot_id=? and member_id = ?",hot_spot_id,member_id]
  end
  
  def self.avg(column,hot_spot_id)
    HotSpotScore.average(column,:conditions => ["hot_spot_id = ?",hot_spot_id])
  end

  def self.count_score(value,hot_spot_id)
    HotSpotScore.count("*", :conditions => ["hot_spot_id = ? and (quality+service+environment+price)/4 = ?", hot_spot_id, value])
  end
  
  private
  def count_in_30day_rate
    HotSpotScore.count :conditions => ['TO_DAYS(NOW()) - TO_DAYS(created_at)  <=  ? and member_id = ? and hot_spot_id = ?', PERIOD_RATE, self.member_id,self.hot_spot_id]
  end
end
