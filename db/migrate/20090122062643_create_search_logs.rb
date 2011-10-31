class CreateSearchLogs < ActiveRecord::Migration
  def self.up
    create_table :search_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :area, :limit=>100
      t.string :keyword, :limit=>100
      t.integer :city_id, :null=>false
      t.integer :member_id
      t.integer :hot_spot_count
      t.boolean :from_mobile
      t.timestamps
    end
  end

  def self.down
    drop_table :search_logs
  end
end
