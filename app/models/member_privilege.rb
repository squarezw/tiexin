class MemberPrivilege < ActiveRecord::Base
  belongs_to :member
  
  validates_presence_of :privilege
end
