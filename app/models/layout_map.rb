class LayoutMap < ActiveRecord::Base
  untranslate :layoutable, :layoutable_type, :layoutable_id
  
  belongs_to :layoutable, :polymorphic=>true     
  has_many :zoom_levels, :dependent=>:destroy, :order=>'scale desc'
  
  acts_as_multilingual_attribute :name
  acts_as_multilingual_attribute :introduction
  
  has_many :positions, :dependent=>:delete_all, :include=>:hot_spot
  has_many :hot_spots, :through=>:positions
  
  validates_presence_of :name
  validates_presence_of :layoutable
  
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil=>true       
  validates_length_of_multilingual_attribute :introduction, :lang => XNavi::SUPPORT_LANGS, :within=>0..1000, :allow_nil=>true       
  
  untranslate :layoutable, :layoutable_type
  
  def hot_spot_categories
    HotSpotCategory.find hot_spot_category_ids
  end
  
  def hot_spot_category_ids
    return (self.hot_spots.collect {|hot_spot| hot_spot.hot_spot_category_id}).uniq
  end

end
