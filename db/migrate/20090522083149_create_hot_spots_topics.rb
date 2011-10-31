class CreateHotSpotsTopics < ActiveRecord::Migration
  def self.up
    create_table :hot_spots_topics, :id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
       t.integer :hot_spot_id, :null=>false
       t.integer :topic_id, :null=>false
       t.timestamps
    end
  end

  def self.down
    drop_table :hot_spots_topics
  end
end
