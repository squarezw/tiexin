class Reply < ActiveRecord::Base
  STATUS_PENDDING = 0
  STATUS_CHECKED = 1
  STATUS_CHECK_FAILED = 2
  
  ALL_CHECK_STATUS = [STATUS_PENDDING, STATUS_CHECKED, STATUS_CHECK_FAILED]
  
  N_('reply_check_status|0')
  N_('reply_check_status|1')
  N_('reply_check_status|2')
  
  VOTE_GOOD = 1
  VOTE_WATER = 2
  VOTE_HIDDEN = 3
  
  N_('reply_vote_result|1')
  N_('reply_vote_result|2')
  N_('reply_vote_result|3')

  SCORE_ATTRIBUTES = {VOTE_GOOD => :good_score, VOTE_WATER=>:water_score, VOTE_HIDDEN=>:hidden_score}
    
  belongs_to :post, :counter_cache=>true
  acts_as_list :scope=> :post
  belongs_to :member
  has_many :votes, :as=>:target, :dependent=>:delete_all
  has_many :operation_logs, :as=>:related_object, :dependent=>:delete_all
  
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
  
  validates_length_of :content, :within => 5..10000
  
  def self.per_page
    10
  end
  
  def votable_to?(member)
    self.vote_result == 0 and
      member and 
      ! (self.member == member) and 
      !(Vote.has_voted?(self, member))
  end
  
  def vote!(member, option)
    raise ArgumentError unless SCORE_ATTRIBUTES.has_key?(option)
    score_attr = SCORE_ATTRIBUTES[option]
    self[score_attr]= self[score_attr] + member.score_weight
    self.votes.create :member=>member, :vote=>option
    if self.post and member.is_moderator?(self.post.forum)
      self.vote_result = option
    elsif self[score_attr] >= 20
      self.vote_result = option
    end    
  end
  
  def deleted!
    self.update_attribute_with_validation_skipping :deleted, true
  end
end
