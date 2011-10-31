class CreateAreas < ActiveRecord::Migration
  def self.up      
    create_table :areas, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|     
      t.column    :city_id,     :integer,     :null=>false
      t.column    :name_en,     :string,      :limit=>60
      t.column    :name_zh_cn,  :string,      :limit=>60
      t.column    :nw_x,       :integer
      t.column    :nw_y,       :integer
      t.column    :width,      :integer
      t.column    :height,     :integer
    end
  end

  def self.down        
    drop_table  :areas
  end
end
