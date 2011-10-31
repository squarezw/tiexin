class AddScoreCountToHotSpots < ActiveRecord::Migration
  def self.up
    add_column :hot_spots, :score_count, :integer, :default => 0
    execute 'update hot_spots  set score_count = (select count(*) from hot_spot_scores where hot_spot_id = hot_spots.id)'
  end

  def self.down
    remove_column :hot_spots, :score_count
  end
end
