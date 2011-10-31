class CreateChannelDailyContents < ActiveRecord::Migration
  def self.up
    create_table :channel_daily_contents, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :channel_id, :null=>false
      t.string :title, :limit=>300, :null=>false
      t.date :display_at, :null=>false
      t.string :picture, :limit=>300
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :channel_daily_contents
  end
end
