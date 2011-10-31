class CreateHotSpots < ActiveRecord::Migration
  def self.up    
    create_table :hot_spots, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t| 
      t.column    :city_id,     :integer,   :null=>false
      t.column    :hot_spot_category_id, :integer
      t.column    :name_en,     :string,    :limit => 180
      t.column    :name_zh_cn,  :string,    :limit => 180
      t.column    :address_en,  :string,    :limit => 180
      t.column    :address_zh_cn, :string,  :limit => 180
      t.column    :x,           :integer
      t.column    :y,           :integer
      t.column    :phone_number,  :string,  :limit=>60
      t.column    :introduction_en, :string,  :limit=>3000
      t.column    :introduction_zh_cn, :string, :limit=>3000        
      t.column    :creator_id,       :integer, :null=>false
      t.column    :approved,      :boolean
      t.column    :created_at,    :datetime 
      t.column    :comments_count, :integer, :default=>0       
    end
  end

  def self.down         
    drop_table   :hot_spots
  end
end
