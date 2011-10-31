class CreateRecommendedHotSpots < ActiveRecord::Migration
  def self.up
    create_table :recommended_hot_spots, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :hot_spot_id, :integer, :null=>false
      t.column :readed, :boolean, :null=>false, :default=>false
      t.column :created_at, :datetime
      t.column :last_recommended_at, :datetime
    end
  end

  def self.down
    drop_table :recommended_hot_spots
  end
end
