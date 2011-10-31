class CreateMembersRecommendedHotSpots < ActiveRecord::Migration
  def self.up
    create_table :members_recommended_hot_spots, :id=>false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :recommended_hot_spot_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :members_recommended_hot_spots
  end
end
