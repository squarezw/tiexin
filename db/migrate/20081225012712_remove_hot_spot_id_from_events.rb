class RemoveHotSpotIdFromEvents < ActiveRecord::Migration
  def self.up
    execute "update events set vendor_type = 'HotSpot', vendor_id=hot_spot_id where hot_spot_id is not null and vendor_id is null"
    remove_column :events, :hot_spot_id
  end

  def self.down
    add_column :events, :hot_spot_id, :integer
    execute "update events set hot_spot_id = vendor_id where vendor_type = 'HotSpot'"
  end
end
