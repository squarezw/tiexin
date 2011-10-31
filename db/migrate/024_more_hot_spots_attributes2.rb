class MoreHotSpotsAttributes2 < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :operation_time_zh_cn, :string, :limit=>600
    add_column :hot_spots, :operation_time_en,:string, :limit => 600
    add_column :hot_spots, :home_page, :string, :limit=>450 
  end

  def self.down
    remove_column :hot_spots, :operation_time_zh_cn
    remove_column :hot_spots, :operation_time_en
    remove_column :hot_spots, :home_page
  end
end
