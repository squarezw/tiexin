class AddMinimumToNaviStars < ActiveRecord::Migration
  def self.up
    add_column :navi_stars, :minimum_release, :integer, :null=>false
    add_column :navi_stars, :minimum_major, :integer, :null=>false
    add_column :navi_stars, :minimum_minor, :integer, :null=>false
  end

  def self.down
    remove_column :navi_stars, :minimum_release 
    remove_column :navi_stars, :minimum_major 
    remove_column :navi_stars, :minimum_minor 
  end
end
