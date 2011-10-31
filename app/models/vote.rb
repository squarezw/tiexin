class Vote < ActiveRecord::Base
  VOTE_AGREE = 1
  VOTE_DISAGREE = 2
  belongs_to :target, :dependent => :delete, :polymorphic => true
  belongs_to :member, :dependent => :delete
  
  untranslate :target, :target_type
  
  def self.has_voted?(target, member)
    return exists?(['target_type = ? and target_id = ? and member_id = ?', target.class.to_s, target.id, member.id])
  end
end
