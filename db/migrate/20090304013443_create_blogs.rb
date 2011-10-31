class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :name,  :null=>false, :limit=>30
      t.string :simple_name,  :null=>false, :limit=>30
      t.string :picture, :limit=>50
      t.integer :skin_id, :null=>false, :default=> 1
      t.integer :owner_id, :null=>false
      t.integer :read_times, :null=>false, :default=>0
      t.datetime :read_time
      t.string :read_ip, :limit=>20
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end