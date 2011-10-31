class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title, :limit=>100, :null=>false
      t.string :banner, :limit=>500
      t.string :summary, :limit=>3000
      t.string :cover_pic, :limit=>500
      t.string :template, :limit=>100
      t.datetime :expire_date
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
