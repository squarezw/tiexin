class AddTrafficStopTypeToHotSpotCategory < ActiveRecord::Migration
  def self.up
    add_column :hot_spot_categories, :traffic_stop_type, :integer, :default=>0
    execute 'update hot_spot_categories set traffic_stop_type = 0'
  end

  def self.down
    remove_column :hot_spot_categories, :traffic_stop_type
  end
end
