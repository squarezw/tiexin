class Friend < ActiveRecord::Base
  belongs_to :owner, :foreign_key=>:owner_id, :class_name=>'Member'
  belongs_to :member
  
  def confirm!  
    self.update_attribute_with_validation_skipping :pending, false
    self.reload
  end
end
