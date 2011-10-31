class AddFieldsToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels, :has_daily_content, :boolean, :default=>false
    add_column :channels, :daily_content_title, :string, :limit=>30
    execute 'update channels set has_daily_content = 0'
  end

  def self.down
    remove_column :channels, :has_daily_content
    remove_column :channels, :daily_content_title
  end
end
