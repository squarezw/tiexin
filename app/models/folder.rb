class Folder < ActiveRecord::Base
  belongs_to :member
  has_many :articles, :dependent=>:nullify 
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>30
  
  def articles_count
    self.articles.count
  end
end
