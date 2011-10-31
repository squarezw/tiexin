class Picture < ActiveRecord::Base
  belongs_to :member
  
  validates_presence_of :name, :member_id, :photo
  validates_length_of :name, :within => 1..100, :allow_nil=>true
  validates_length_of :tag_list, :within => 1..100, :allow_nil=>true
  
  image_column :photo, :validate_integrity=>false,
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    }, 
                :versions=> {:small=>'128x128', :normal=>'512x512'}
end