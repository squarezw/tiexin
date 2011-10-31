class BlogAccessLog < ActiveRecord::Base
  belongs_to :member
  belongs_to :blog
  
  validates_presence_of :member_id
  
  def self.visited(user)
    last_user = self.find(:first, :order => "id desc")
    if last_user  and last_user.member != user
      return true
    else
      return false
    end
  end
  
  def self.write_log(member,blog)
    if member and blog and member != blog.owner and visited(member)
      BlogAccessLog.create  :member=>member, :blog => blog
    end
  end
  
end
