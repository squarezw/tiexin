class AddVisitCountToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :visit_count, :integer, :default=>0
    execute 'update hot_spots set visit_count = 0'
  end

  def self.down
    remove_column :hot_spots, :visit_count
  end
end
