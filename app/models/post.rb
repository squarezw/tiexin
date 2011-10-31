class Post < ActiveRecord::Base
  VOTE_GOOD = 1
  VOTE_WATER = 2
  VOTE_HIDDEN = 3
  
  N_('post_check_status|0')
  N_('post_check_status|1')
  N_('post_check_status|2')
  
  N_('post_vote_result|0')
  N_('post_vote_result|1')
  N_('post_vote_result|2')
  N_('post_vote_result|3')

  SCORE_ATTRIBUTES = {VOTE_GOOD => :good_score, VOTE_WATER=>:water_score, VOTE_HIDDEN=>:hidden_score}
  STATUS_PENDDING = 0
  STATUS_CHECKED = 1
  STATUS_CHECK_FAILED = 2
  ALL_CHECK_STATUS = [STATUS_PENDDING, STATUS_CHECKED, STATUS_CHECK_FAILED]
  
  belongs_to :forum
  belongs_to :member
  has_many :replies, :dependent=>:delete_all, :order=>'position'
  has_many :votes, :as=>:target, :dependent=>:delete_all
  has_many :operation_logs, :as=>:related_object, :dependent=>:delete_all
  has_one :article
  has_one :reply,  :order=>'id desc'
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :tags, :uniq=>true
  
  image_column :attachment, 
               :versions => {:thumb=>'200x200'},
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                      ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
               :filename=> proc{|inst, original, ext| original + ( ext.blank? ? '' : ".#{ext}" ).downcase },
               :validate_integrity=>true
  
  validates_presence_of :title
  validates_length_of :title, :maximum=>100, :allow_nil=>true
  has_one :content_ref, :class_name=>'Content', :dependent => :destroy    
  
  def self.per_page
    25
  end
  
  def self.posts_for_homepage(limit=5)
    self.find :all, :conditions=>['show_in_homepage = ?', true], :order=>'created_at desc', :limit=>limit
  end
  
  def content=(c)                            
    self.content_ref=self.build_content_ref if self.content_ref.nil?
    self.content_ref.content = c
    @content_modified=true
  end                        
  
  def content                  
    return '' if self.content_ref.nil?
    self.content_ref.content
  end
  
  def read!
    update_attribute_with_validation_skipping :read_times, self.read_times + 1
  end
  
  def replied!
#    update_attribute_with_validation_skipping :last_replied_at, Time.now
    Post.update_all "last_replied_at = current_timestamp ()", "id=#{self.id}"
  end
  
  def modifiable_to?(member)
    return self.member == member
  end
  
  def before_create
    self.last_replied_at = Time.now
  end
  def after_save
    self.content_ref.save! if @content_modified and self.content_ref
    @content_modified=false
  end
  
  def validate
    self.errors.add :content, self.content_ref.errors[:content] unless self.content_ref.valid?
  end
  
  def votable_to?(member)
      self.vote_result == 0 and
      member and 
      ! (self.member == member) and 
      ! (Vote.has_voted?(self, member))
  end
  
  def vote!(member, option)
    raise ArgumentError unless SCORE_ATTRIBUTES.has_key?(option)
    score_attr = SCORE_ATTRIBUTES[option]
    self[score_attr]= self[score_attr] + member.score_weight
    self.votes.create :member=>member, :vote=>option
    if member.is_moderator?(self.forum)
      self.vote_result = option
    elsif self[score_attr] >= 30
      self.vote_result = option
    end
  end
  
  def is_hidden?
    self.vote_result == VOTE_HIDDEN
  end
  
  def put_to_top!
    self.always_on_top = true unless self.is_hidden?
  end

  def remove_from_top!
    self.always_on_top = false
  end
  
  def lock!
    self.lock = true unless self.is_hidden?
  end
  
  def remove_lock!
    self.lock = false
  end  
  
  def deleted!
    self.update_attribute_with_validation_skipping :deleted, true
  end
  
  def self.new_posts(limit=5)
   self.find :all, 
                    :conditions=>['deleted = ? and vote_result != ? and check_status = ?', false, VOTE_HIDDEN, STATUS_CHECKED],
                    :order=>'created_at desc', :limit=>limit    
  end
  
  def self.hot_posts(limit=5)
   self.find :all, 
                    :conditions=>['deleted = ? and vote_result != ? and check_status = ?', false, VOTE_HIDDEN, STATUS_CHECKED],
                    :order=>'read_times desc', :limit=>limit    
  end
  
  def self.best_posts(limit=5)
   self.find :all, 
                    :conditions=>['deleted = ? and vote_result != ? and check_status = ? and vote_result = ?', false, VOTE_HIDDEN, STATUS_CHECKED, VOTE_GOOD],
                    :order=>'created_at desc', :limit=>limit 
  end

  def tags_string
    (self.tags.collect { |tag| tag.tag }).join(',')
  end
  
  def tags_string=(str)
    if str.nil? or str.empty?
      self.tags.clear
      return
    end
    
    new_tags = str.strip.split(/\s*[,，]\s*/)
    self.tags.each do |old_tag|
      self.tags.delete(old_tag) unless new_tags.include?(old_tag.tag)
    end
    
    new_tags.each do |new_tag|
      tag = Tag.find_or_create_by_tag new_tag
      self.tags << tag unless self.tags.include?(tag)
    end
  end
  
  def flip_show_in_homepage!
    self.show_in_homepage = !self.show_in_homepage
    self.save_with_validation false
  end
  
end
