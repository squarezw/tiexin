class CreateLayoutMaps < ActiveRecord::Migration
  def self.up               
    create_table :layout_maps, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|
      t.column      :name_en,       :string,  :limit => 60  
      t.column      :name_zh_cn,    :string,  :limit => 60
      t.column      :layoutable_type, :string, :null=>false
      t.column      :layoutable_id,   :integer, :null=>false 
    end    
  end

  def self.down
  end
end
