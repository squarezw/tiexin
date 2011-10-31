require 'RMagick' 
    
class NaviPhoto < ActiveRecord::Base      
  belongs_to :owner, :polymorphic => true   
  belongs_to :uploader, :class_name=>'Member', :foreign_key=>'uploader_id'
  image_column :photo, 
               :versions => {:thumb=>'128x128', :mobile=>'200x120', :small_thumb=>'90x90', :big_thumb => '500x1000'},
               :force_format => 'jpg',
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                      ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
               :filename=> proc{|inst, original, ext| original + ( ext.blank? ? '' : ".#{ext}" ).downcase },
               :validate_integrity=>true

  validates_presence_of :photo, :message=>_('An image file is required.')
      
  validates_presence_of :subject
  validates_length_of :subject, :maximum => 100
  validates_presence_of :owner
  
  untranslate :owner_type, :owner
  
  def self.per_page
    12
  end
  
  def modifiable_to?(user)
    user and (user.is_admin or user == self.uploader or user.has_privilege(:modify_hot_spot))
  end
   
  def photo_after_assign
    img = Magick::Image::read(photo.path)[0]
    img = img.resize_to_fit 128, 128
    img.write(photo.mobile.path) { self.quality = 20 }
  end 
  
  def owner_uploaded?
    self.owner.respond_to?(:owner) and self.owner.owner == self.uploader
  end
end
