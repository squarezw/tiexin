class AddMoreFieldsToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :photo, :string, :limit=>100
    add_column :cities, :weather_code, :string, :limit=>2048
  end

  def self.down
    remove_column :cities, :photo
    remove_column :cities, :weather_code
  end
end
