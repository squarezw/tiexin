class CreateRoadSegments < ActiveRecord::Migration
  def self.up
    create_table :road_segments, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :road_id, :integer, :null=>false
      t.column :start_x, :integer, :null=>false
      t.column :start_y, :integer, :null=>false
      t.column :end_x, :integer, :null=>false
      t.column :end_y, :integer, :null=>false
    end
  end

  def self.down
    drop_table :road_segments
  end
end
