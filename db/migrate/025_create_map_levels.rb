class CreateMapLevels < ActiveRecord::Migration
  def self.up
    create_table :map_levels, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column  :city_id,  :integer, :null=>false
      t.column  :no,      :integer, :null=>false
      t.column  :scale,   :float, :null=>false
      t.column  :row,     :integer, :null=>false
      t.column  :column,  :integer, :null=>false
    end
  end

  def self.down
    drop_table :map_levels
  end
end
