class CreateHotSpotScores < ActiveRecord::Migration
  def self.up
    create_table :hot_spot_scores, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :hot_spot_id, :integer, :null=>false
      t.column :member_id, :integer, :null=>false
      t.column :quality, :integer,  :default=>0
      t.column :service, :integer, :default=>0
      t.column :environment, :integer, :default=>0
      t.column :price, :integer, :default=>0
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :hot_spot_scores
  end
end
