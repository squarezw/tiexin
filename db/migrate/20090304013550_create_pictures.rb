class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :name,  :null=>false, :limit=>30
      t.string :photo
      t.string :tag_list, :limit=>100
      t.string :description, :limit=>1000
      t.integer :read_times, :null=>false, :default=>0
      t.integer :member_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end