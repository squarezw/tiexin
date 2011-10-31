class AddMoreFieldsToAccessLogs < ActiveRecord::Migration
  def self.up
    add_column :access_logs, :browser, :string, :limit=>50
    add_column :access_logs, :browser_version, :string, :limit=>50
    add_column :access_logs, :from_robot, :boolean
  end

  def self.down
    remove_column :access_logs, :browser
    remove_column :access_logs, :browser_version
    remove_column :access_logs, :from_robot
  end
end
