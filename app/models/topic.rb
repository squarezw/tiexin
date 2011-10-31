class Topic < ActiveRecord::Base
  
  image_column :banner, :validate_integrity=>false
  image_column :cover_pic, :validate_integrity=>false
  
  validates_presence_of :title
  validates_integrity_of :banner, :cover_pic
  
  belongs_to :city
  has_one :topic_expo
  has_many  :photos, :as => :owner, :class_name=>'NaviPhoto', :dependent=>:destroy
  has_many :comments, :class_name => "Comment", :finder_sql =>
             'SELECT c.* ' +
             'FROM hot_spots_topics ht, comments c ' +
             'WHERE ht.hot_spot_id = c.commentable_id  AND c.commentable_type = "HotSpot" And ht.topic_id = #{id} ' +
             'ORDER BY c.id'

  has_and_belongs_to_many :articles
  has_and_belongs_to_many :posts
  has_and_belongs_to_many :hot_spots
    
  def id_of_all_article_topic_id
    self.articles.collect {|cat| cat.id}
  end

  def id_of_all_post_topic_id
    self.posts.collect {|cat| cat.id}
  end  
  
  def id_of_all_hot_spot_topic_id
    self.hot_spots.collect {|cat| cat.id}
  end
  
  def name
    self.title
  end
  
  def self.back_topics(current_city)
    current_city.topics.find(:all, :conditions => ["expire_date < now()"])
  end

  def self.expo
    find_by_title("世博专题")
  end
end
