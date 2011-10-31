class Brand < ActiveRecord::Base
  include URI::REGEXP::PATTERN;
  
  HTTP_HTTPS_SCHEME="HTTP|HTTPS"
  HOME_PAGE_URI=Regexp.new("(#{HTTP_HTTPS_SCHEME}:(?:#{HIER_PART}|#{OPAQUE_PART}))|(^$)", true)
  
  CAPABILITY_INTRODUCTION = 1
  CAPABILITY_HOT_SPOTS = 2
  CAPABILITY_PRODUCTS = 3
  CAPABILITY_PROMOTIONS = 4
  
  has_many   :hot_spots, :dependent=>:nullify
  has_many   :products, :dependent=>:destroy, :as=>:vendor
  has_many   :events, :as=>:vendor, :dependent=>:destroy

  has_many   :promotions, :dependent=>:destroy, :as=>:vendor
  belongs_to :owner, :class_name=>'Member', :foreign_key=>:owner_id
  belongs_to :creator, :class_name=>'Member', :foreign_key=>:creator_id
  belongs_to :hot_spot_category
  
  image_column :pic, :validate_integrity=>false,
                 :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :versions=> {:small=>'90x90', :mobile=>'120x80'}
  
  validates_integrity_of :pic
  
  acts_as_multilingual_attribute :name
  
  validates_presence_of :name, :hot_spot_category_id
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..60, :allow_nil => true
  validates_length_of :home_page, :allow_nil=>true, :maximum=>150, :message => _('Can not be longer than %{length}') % { :length=>150 }
  validates_format_of :home_page, :with => HOME_PAGE_URI, :allow_nil=>true, :message => _('is not a valid HTTP/HTTPS URL')
  
  def self.roots
    self.find_all_by_parent_id(nil)
  end
  
  def latest_products(limit=5)
    self.products.find(:all, :order=>'updated_at desc, created_at desc', 
                       :limit=>limit)
  end
  
  def visit_count!
    self.class.increment_counter :visit_count, id
  end
  
  # retrieves brand ordered by visit_count
  def self.find_ordered(options = {})
    find :all, options.update(:order => 'visit_count desc')
  end
  
  def vendor_id
     self.id
  end
  
  def pic_after_assign
    return unless self.pic
    img = Magick::Image::read(self.pic.path)[0]
    img = img.resize_to_fit 120, 80
    img.write(self.pic.mobile.path) { self.quality = 20 }
    self.pic.process! do |img|
      img.resize_to_fit 180, 100
    end
  end

  def latest_comments(city, limit=10)
    city_id = city.is_a?(City) ? city.id : city.to_s
    Comment.find :all, :conditions=>['commentable_type = ? and commentable_id in (select id from hot_spots where hot_spots.city_id = ? and hot_spots.brand_id = ?)', 'HotSpot', city_id, self.id], :order=>'created_at desc', :limit=>10
  end
  
  def latest_articles(city, limit=10)
    city_id = city.is_a?(City) ? city.id : city.to_s
    Article.find :all, :conditions=>['exists (select * from articles_hot_spots inner join hot_spots on articles_hot_spots.hot_spot_id = hot_spots.id where hot_spots.city_id = ? and hot_spots.brand_id = ? and articles_hot_spots.article_id = articles.id)', city_id, self.id], :order=>'created_at desc', :limit=>10
  end
  
  def merge_from(source)
    HotSpot.update_all(["brand_id=?",self.id],:brand_id => source.id)
    source.destroy
  end  
  
  def count_hot_spots_in_city(city_id)
    self.hot_spots.count :conditions=>['city_id = ?', city_id]
  end
  
  def promotions_for_city(city,limit='1')
      return self.promotions.find(:all,
        :conditions => ["(events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?))  and end_date >= ?", city.id, Time.now.to_date], :limit=>limit)
  end
  
  def count_promotions_for_city(city_id)
      self.promotions.count :conditions => ["(events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?))  and end_date >= ?", city_id, Time.now.to_date]
  end
  
  def capabilities(city_id)
    capabilities = []
    capabilities << CAPABILITY_INTRODUCTION unless self.intro.nil? or self.intro.empty?
    capabilities << CAPABILITY_HOT_SPOTS if count_hot_spots_in_city(city_id) > 0
    capabilities << CAPABILITY_PRODUCTS if self.products.count > 0
    capabilities << CAPABILITY_PROMOTIONS if self.count_promotions_for_city(city_id) > 0
    return capabilities
  end
  
  def recommend_for_brand(expire_month)
    HotSpot.update_all({:recommend => true, :recommend_expire_at => Time.now.since(expire_month.month)}, ["brand_id=?",self.id])
  end
  
end
