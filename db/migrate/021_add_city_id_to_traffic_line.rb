class AddCityIdToTrafficLine < ActiveRecord::Migration
  def self.up
    add_column :traffic_lines, :city_id, :integer
  end

  def self.down
    remove_column :traffic_lines, :city_id
  end
end
