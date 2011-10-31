class MobileOs < ActiveRecord::Base
  has_many :mobile_models, :dependent=>:delete_all
  has_one :navi_star, :dependent=>:delete

  validates_presence_of :name
  validates_uniqueness_of :name
  
end
