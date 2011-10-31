class CreateHotSpotAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :hot_spot_access_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer
      t.column :hot_spot_id, :integer, :null=>false
      t.column :created_at, :datetime
      t.column :from_mobile, :boolean
    end
  end

  def self.down
    drop_table :hot_spot_access_logs
  end
end
