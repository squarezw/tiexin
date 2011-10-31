class MobileModel < ActiveRecord::Base
  belongs_to :mobile_brand
  belongs_to :mobile_os
  
  validates_presence_of :name
  
  image_column :picture, :validate_integrity=>false,
                 :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    }
 
  def picture_after_assign
    self.picture.process! do |image|
      image.resize_to_fit 35, 70
    end
  end
  
end
