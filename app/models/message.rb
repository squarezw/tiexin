class Message < ActiveRecord::Base
  belongs_to :member_from, :class_name=>'Member', :foreign_key => 'from_id'
  belongs_to :member_to, :class_name=>'Member', :foreign_key => 'to_id'
  
  validates_presence_of :title,:content
  validates_presence_of :to_id, :message => N_('Member name no found')
  
  validates_length_of :title, :within=>0..100
  validates_length_of :content, :within=>0..1000
  
  def self.per_page
    10
  end
  
  def self.set_readed(id)
    self.update_all ['readed = true'],   ['id = ?', id]
  end
  
  def self.has_not_read_message_count(id)
    count :conditions=>['to_id = ? and readed = 0', id]
  end
  
  def can_delete?
    self.sender_deleted == true and  self.receiver_deleted==true
  end
  
  def deleted_from_sender
    self.update_attribute :sender_deleted, true
  end

  def deleted_from_receiver
    self.update_attribute :receiver_deleted, true
  end
end
