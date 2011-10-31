class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true  do |t|
      t.integer :city_id
      t.string  :name_en, :limit => 180 
      t.string  :name_zh_cn, :limit => 180      
      t.timestamps
    end
  end

  def self.down
    drop_table :districts
  end
end
