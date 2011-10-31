class Channel < ActiveRecord::Base
  belongs_to :hot_spot_category
  belongs_to :forum
  has_many :channel_daily_contents, :dependent=>:delete_all, :order=>'display_at desc'
  
  image_column :icon, :validate_integrity=>false
  
  acts_as_multilingual_attribute :name
  
  validates_integrity_of :icon
  validates_presence_of :hot_spot_category
  validates_presence_of :forum
  validates_uniqueness_of :hot_spot_category_id
  validates_presence_of :icon
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil => true
  validates_length_of :daily_content_title, :maximum=>10
  
  def daily_content_for(date)
    self.channel_daily_contents.find :first, :conditions=>['display_at <= ?', date], :order=>'display_at desc, created_at desc'
  end
  
end
