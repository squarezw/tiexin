class CreateHotels < ActiveRecord::Migration
  def self.up
    create_table :hotels, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :hot_spot_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :hotels
  end
end
