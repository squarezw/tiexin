class Article < ActiveRecord::Base
  STATUS_PENDDING = 0
  STATUS_CHECKED = 1
  STATUS_CHECK_FAILED = 2
  ALL_CHECK_STATUS = [STATUS_PENDDING, STATUS_CHECKED, STATUS_CHECK_FAILED]
  N_('article_check_status|0')
  N_('article_check_status|1')
  N_('article_check_status|2')

  attr_protected :check_status
  
  belongs_to :member
  belongs_to :folder
  #belongs_to :hot_spot
  belongs_to :brand
  belongs_to :rss_source
  belongs_to :post
  
  has_many :operation_logs, :as=>:related_object, :dependent=>:delete_all
  
  has_and_belongs_to_many :hot_spots
  has_and_belongs_to_many :topics
  
  has_many :comments, :as=>:commentable
  validates_presence_of :subject, :summary, :content
  validates_length_of :summary, :maximum=>1000, :allow_nil => true
  
  def self.per_page
    10
  end
  
  def self.latest_articles(limit=10)
    self.find :all, :conditions => ["check_status = ?",STATUS_CHECKED], :order=>'created_at desc', :limit=>limit
  end

  def self.recommend_articles(limit=15)
    self.find :all, :conditions => ["check_status = ? and recommended = true",STATUS_CHECKED], :order=>'created_at desc', :limit=>limit
  end
  
  def self.articles_for_city(city, options={})
    options = ({:page=>1}).merge options
    self.paginate_by_sql "select a.* from articles a where a.check_status = 1 and not exists (select * from articles_hot_spots ah where ah.article_id = a.id) or exists (select * from articles_hot_spots ah, hot_spots h where a.id = ah.article_id and ah.hot_spot_id = h.id and h.city_id = #{city.id}) order by a.updated_at desc, a.created_at desc", options
  end
  
  def self.articles_for_hot_spot(hot_spot, options={})
    options = ({:page=>1}).merge options
    options = options.merge :include=>:hot_spots, :conditions=>['hot_spots.id = ?', hot_spot.id], :order=>'articles.created_at desc'
    self.paginate options
  end
  
  def id_of_all_hot_spot_article_id
    self.hot_spots.collect {|cat| cat.id}
  end

  def read!
    update_attribute_with_validation_skipping :read_times, self.read_times + 1
  end
  
  def approve!
    self.check_status = STATUS_CHECKED
    self.save_with_validation false
  end
  
  def disapprove!
    self.check_status = STATUS_CHECK_FAILED
    self.save_with_validation false
  end

  def recommend!
    self.recommended = 1
    self.save_with_validation false
  end

  def cancel_recommend!
    self.recommended = 0
    self.save_with_validation false
  end

  def older_than(newer)
    return true if self.synch_date and newer.date and (self.synch_date < newer.date)    
    return true if (self.subject != newer.title or
                    self.content != newer.description)
  end 

  def to_rss(xml)
    xml.item do
      xml.title(subject)
      xml.description(content)
      xml.pubDate(created_at)
      xml.guid(id)
      xml.link("http://#{XNavi::DOMAIN_NAME}/articles/#{id}")
    end
  end  

end
