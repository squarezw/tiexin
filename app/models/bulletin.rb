class Bulletin < ActiveRecord::Base
  validates_presence_of :title
  validates_length_of :title, :maximum => 300
  validates_presence_of :content
  validates_presence_of :language
  
  def self.latest_bulletin(language='zh_cn', limit='4')
    self.find  :all, 
               :conditions=>['language=? and expire_date >= ? ', language.to_s, Time.now.to_date],
               :limit=>limit,
               :order=>'created_at desc'
  end
end
