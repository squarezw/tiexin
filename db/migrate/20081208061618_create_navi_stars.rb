class CreateNaviStars < ActiveRecord::Migration
  def self.up
    create_table :navi_stars, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :release,  :null=>false
      t.integer :major,  :null=>false
      t.integer :minor,  :null=>false
      t.string :suffix
      t.string :filename
      t.integer :mobile_os_id
      t.timestamps
    end
  end

  def self.down
    drop_table :navi_stars
  end
end
