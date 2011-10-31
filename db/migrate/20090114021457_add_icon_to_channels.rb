class AddIconToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels, :icon, :string, :limit=>100
  end

  def self.down
    remove_column :channels, :icon
  end
end
