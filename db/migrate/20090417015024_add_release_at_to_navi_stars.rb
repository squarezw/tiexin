class AddReleaseAtToNaviStars < ActiveRecord::Migration
  def self.up
    add_column :navi_stars, :release_at,  :datetime
  end

  def self.down
    remove_column :navi_stars, :release_at
  end
end
