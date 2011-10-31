class RecommendedHotSpot < ActiveRecord::Base
  belongs_to :hot_spot
  belongs_to :member
  has_and_belongs_to_many :recommenders, :class_name=>'Member', :join_table=>'members_recommended_hot_spots', :uniq=>true
  
  def add_recommender(recommender)
    self.recommenders<< recommender unless self.recommender_ids.include?(recommender.id)
  end
  
  def readed!
    self.update_attribute_with_validation_skipping(:readed, true) unless self.readed
  end
end
