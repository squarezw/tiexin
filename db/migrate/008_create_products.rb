class CreateProducts < ActiveRecord::Migration
  def self.up  
    create_table :products, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|                    
      t.column    :hot_spot_id, :integer, :null=>false
      t.column    :name_en,   :string,  :limit=>300
      t.column    :name_zh_cn, :string, :limit=>300
      t.column    :official, :boolean, :null=>false, :default => false
      t.column    :introduction_en, :string, :limit=>3000
      t.column    :introduction_zh_cn, :string, :limit=>3000 
      t.column    :photo, :string
      t.column    :creator_id, :integer
      t.column    :last_updater_id, :integer
      t.column    :created_at, :datetime
      t.column    :updated_at, :datetime
    end
  end

  def self.down
    drop_table :products
  end
end
