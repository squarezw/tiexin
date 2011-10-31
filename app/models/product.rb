class Product < ActiveRecord::Base
  belongs_to :vendor, :polymorphic=>true                   
  belongs_to :creator, :class_name => 'Member', :foreign_key => 'creator_id'
  belongs_to :last_updater, :class_name => 'Member', :foreign_key => 'last_updater_id' 
  has_many   :comments, :as => :commentable
  has_many   :votes, :as => :target
  
  validates_presence_of :name
  
  image_column :photo , 
               :versions => {:thumb => '128x128', :mobile=>'256x256', :small_thumb=>'90x90'},
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :validate_integrity=>false
   
  acts_as_multilingual_attribute :name
  acts_as_multilingual_attribute :introduction     
  
  validates_length_of :price, :maximum => 100
  #validates_presence_of :photo, :message=>_('An image file is required.')  
  
  def self.per_page
    12
  end
  
  def modifiable_to?(user)
    user and (user.is_admin or self.creator == user)
  end
  
  def recent_comments(limit=10)
    self.comments.find(:all,
                       :order => 'created_at desc', 
                       :limit => limit )
  end
  
  def owner_recommended?
    self.vendor.respond_to?(:owner) and self.vendor.owner == self.creator
  end
  
  def official?
    self.owner_recommended?
  end
  
  def random_photo
    return nil if self.photos.empty?
    # 原来用的:order => rand() 要改进
    self.photos.find :first, :order => 'id desc'
  end
  
  def photo_after_assign
    return unless self.photo
    img = Magick::Image::read(self.photo.path)[0]
    img = img.resize_to_fit 256,256
    img.write(photo.mobile.path) { self.quality = 20 }
  end
  
end
