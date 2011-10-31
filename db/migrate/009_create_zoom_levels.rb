class CreateZoomLevels < ActiveRecord::Migration
  def self.up 
    create_table :zoom_levels, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|               
      t.column :layout_map_id, :integer, :null=>false
      t.column :width,      :integer,  :null=>false
      t.column :height,     :integer,  :null=>false
      t.column :scale,      :integer,  :null=>false, :default=>1    
      t.column :map_file, :string 
      t.column :height,   :integer
      t.column :width,    :integer
      t.column :map_file_width, :integer
      t.column :map_file_height, :integer
    end
  end

  def self.down                                                 
    drop_table :zoom_levels
  end
end
