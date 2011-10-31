class ChannelDailyContent < ActiveRecord::Base
  belongs_to :channel
  image_column :picture, 
               :old_files => :delete,
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :filename=> proc{|inst, original, ext| original + ( ext.blank? ? '' : ".#{ext}" ).downcase },
                :validate_integrity=>true
                
  validates_presence_of :title
  validates_length_of :title, :maximum=>100, :allow_nil=>true
  validates_presence_of :display_at
  
  def self.per_page
    20
  end
  
  def picture_after_assign
    self.picture.resize! '250x140'
  end
  
  def history_contents(limit=10)
    self.channel.channel_daily_contents.find :all, 
          :conditions=>['display_at <= ? and id <> ?', self.display_at, self.id],
          :order=>'display_at desc, created_at desc',
          :limit=>limit
  end
  
end
