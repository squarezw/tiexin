class AddOperationTimeToTrafficLines < ActiveRecord::Migration
  def self.up
    add_column :traffic_lines, :operation_time_zh_cn, :string, :limit=>600
    add_column :traffic_lines, :operation_time_en, :string, :limit=>600
  end

  def self.down
    remove_column :traffic_lines, :operation_time_zh_cn
    remove_column :traffic_lines, :operation_time_en
  end
end
