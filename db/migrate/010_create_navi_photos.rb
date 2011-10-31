class CreateNaviPhotos < ActiveRecord::Migration
  def self.up 
    create_table :navi_photos, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|                            
      t.column :owner_type,     :string, :null => false
      t.column :owner_id,       :integer, :null=>false
      t.column :subject,        :string, :limit=>300
      t.column :photo,          :string     
      t.column :uploader_id,       :integer, :null=>false
      t.column :created_at,     :datetime
    end
  end

  def self.down     
    drop_table :navi_photos
  end
end
