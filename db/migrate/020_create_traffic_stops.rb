class CreateTrafficStops < ActiveRecord::Migration
  def self.up
    create_table :traffic_stops, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :traffic_line_id, :integer, :null=>false
      t.column :position, :integer, :default=>0, :null=>false
      t.column :hot_spot_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :traffic_stops
  end
end
