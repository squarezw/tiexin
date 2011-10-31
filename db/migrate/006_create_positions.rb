class CreatePositions < ActiveRecord::Migration
  def self.up  
    create_table :positions, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t| 
      t.column      :hot_spot_id,       :integer, :null=>false
      t.column      :layout_map_id,     :integer, :null=>false
      t.column      :x,                 :double,  :null=>false
      t.column      :y,                 :double,  :null=>false
    end
  end

  def self.down            
    drop_table :positions
  end
end
