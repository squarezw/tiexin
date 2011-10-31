require 'imon_exception'

class Forum < ActiveRecord::Base
  has_many :posts, :dependent=>:destroy
  has_and_belongs_to_many :members
  has_and_belongs_to_many :blacklist_to_members, :join_table => :bbs_blacklists, :class_name => 'Member'
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>50
  validates_length_of :description, :maximum=>2000
  
  attr_protected :order_sequence
  
  def can_delete?
    self.posts.empty?
  end
  
  def before_destroy
    return true if self.posts.empty?
    raise Imon::CantDestroyException 
  end
  
  def today_post_count
    Post.count :conditions => ['forum_id= ? and created_at between ? and ?', self.id, Date.today, Date.today.tomorrow - 1]
  end
  
  def latest_post
    posts = self.latest_posts 1
    posts.empty? ? nil : posts[0]
  end
  
  def latest_posts(limit=10)
    self.posts.find :all, 
                    :conditions=>['deleted = ? and vote_result != ? and check_status = ?', false, Post::VOTE_HIDDEN, Post::STATUS_CHECKED],
                    :order=>'created_at desc', :limit=>limit    
  end
  
  def top_posts
    self.posts.find :all, :conditions=>['always_on_top = ? and vote_result <> ?', true, Post::VOTE_HIDDEN],
                    :order=>'created_at desc'
  end
  
  def best_posts(limit=5)
    self.posts.find :all, :conditions=>['vote_result = ? and vote_result <> ?', Post::VOTE_GOOD, Post::VOTE_HIDDEN],
                    :order=>'created_at desc',:limit => limit
  end

  def original_posts(limit=5)
    self.posts.find :all, :conditions=>['original = ? and vote_result <> ?', true, Post::VOTE_HIDDEN],
                    :order=>'created_at desc',:limit => limit
  end  


  def blog_posts(limit=5)
    self.posts.find :all, :conditions=>[' vote_result <> ?',  Post::VOTE_HIDDEN],
                    :order=>'created_at desc',:limit => limit, :joins => "inner join articles on posts.id = articles.post_id"
  end
  
  def not_hidden_posts_count
      self.posts.count :conditions=>['vote_result <> ? and deleted <> ?', Post::VOTE_HIDDEN, true]
  end
  
  def visible_posts_count
    self.posts.count :conditions=>['vote_result <> ? and deleted <> ? and check_status = ?', Post::VOTE_HIDDEN, true, Post::STATUS_CHECKED]
  end
  
  def blacklist_after_lock_post(member)
    Post.update_all(["posts.lock=1"], ["member_id = ? and forum_id = ?",member.id,  self.id])
  end
  
end
