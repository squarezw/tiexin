class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.integer :hot_spot_category_id, :null=>false
      t.integer :forum_id, :null=>false
    end
  end

  def self.down
    drop_table :channels
  end
end
