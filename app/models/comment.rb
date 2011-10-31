class Comment < ActiveRecord::Base
  STATUS_PUBLISHED = 1
  STATUS_WAITING_CHECK = 2
  STATUS_CHECK_FAILED = 3
  N_('comment_status|1')
  N_('comment_status|2')
  N_('comment_status|3')
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :member  
    
  has_many :votes, :as=>:target
  
  validates_length_of :content, :minimum => 10 
  validates_presence_of :commentable
  validates_presence_of :status
  validates_inclusion_of :status, :in => [STATUS_PUBLISHED, STATUS_WAITING_CHECK, STATUS_CHECK_FAILED] 
  
  def self.per_page
    10
  end
  
  def waiting_check?
    self.status == STATUS_WAITING_CHECK
  end                                
  
  def pass_check!
    self.status = STATUS_PUBLISHED
  end
  
  def can_vote_by?(member)
    return !(member.nil? or self.member == member or Vote.has_voted?(self, member))
  end
  def agree_by(member)
    self.votes.create :member=>member, :vote=>Vote::VOTE_AGREE
    self.agree += 1
  end

  def disagree_by(member)
    self.votes.create :member=>member, :vote=>Vote::VOTE_DISAGREE
    self.disagree += 1
  end
  
  def owner_commented?
    self.commentable.respond_to?(:owner) and self.commentable.owner == self.member
  end
end
