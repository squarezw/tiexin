require 'crop_picture'

class ZoomLevel < ActiveRecord::Base    
  belongs_to :layout_map
  image_column :map_file, 
               :versions => {:large=>'128x128'}, 
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
               :validate_integrity=>false
  validates_integrity_of :map_file
  validates_presence_of :map_file, :message=>_('An image file is required.')
  validates_presence_of :scale
  
  def after_create
    return unless self.map_file
    Imon::ImageSpliter.new({ :dest_path => self.map_path, 
                             :block_width => 128,
                             :block_height => 128 }).split(self.map_file.path)
  end 
  
  def after_destroy
    path = self.map_path
    return unless File.exists?(path) and File.directory?(path)
    Dir.foreach(path) do |filename|
      File.delete(File.join(path, filename)) unless filename == '.' or filename == '..'
    end                                     
    begin
      Dir.delete(path)
    rescue SystemCallError
    end
  end        
  
  protected 
  def map_path
    File.join(RAILS_ROOT, 'public', 'images', 'maps', (self.id / 200).to_s,  self.id.to_s)
  end
end
