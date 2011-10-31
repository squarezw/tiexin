class DaqEvent < ActiveRecord::Base
  def published
    self.update_attribute_with_validation_skipping :published, true
  end
end
