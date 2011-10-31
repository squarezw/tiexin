class AddStatusToDaqEvents < ActiveRecord::Migration
  def self.up
    add_column :daq_events, :published, :boolean
  end

  def self.down
    remove_column :daq_events, :published
  end
end
