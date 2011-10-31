class CreateDaqEvents < ActiveRecord::Migration
  def self.up
    create_table :daq_events do |t|
      t.string :event_name
      t.string :event_content, :limit => 20000
      t.string :hot_spot_name
      t.string :hot_spot_address
      t.string :picture
      t.datetime :start_date
      t.datetime :end_date
      t.integer :event_category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :daq_events
  end
end
