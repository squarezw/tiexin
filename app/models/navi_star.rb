class NaviStar < ActiveRecord::Base
  belongs_to :mobile_os
  
  validates_uniqueness_of :mobile_os_id
  validates_presence_of :filename, :release, :major, :minor, :suffix, :minimum_release, :minimum_major, :minimum_minor
  
  upload_column :filename,
                 :validate_integrity=>false,
                 :store_dir => "#{RAILS_ROOT}/public/navistar",
                 :filename => proc{|inst, orig, ext| "#{inst.get_version}.#{inst.suffix}"}
              
  def get_version
    "NaviStar_#{self.mobile_os.name}_#{self.release}.#{self.major}.#{self.minor}"
  end
  
  def is_minimum_release(mobile_os_id,release,major,minor)
    self.find(:all, :conditions => ["mobile_os_id = ? and minimum_release = ? and minimum_major = ? and minimum_minor = ?",mobile_os_id,release,major,minor]).count.zero?
  end

  def get_operation_manual_name
    "NaviStar_#{self.mobile_os.name}_#{self.release}"
  end
  
  def update_release_at
    self.release_at = Time.now
  end
end
