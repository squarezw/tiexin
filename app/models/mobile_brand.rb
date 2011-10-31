class MobileBrand < ActiveRecord::Base
  has_many :mobile_models, :dependent=>:delete_all
  
  validates_presence_of :name,:logo
  image_column :logo, :validate_integrity=>false,
                 :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :versions=> {:small=>'100x50', :normal=>'160x80'}  
end
