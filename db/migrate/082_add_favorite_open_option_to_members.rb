class AddFavoriteOpenOptionToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :favorite_open_option, :integer, :default => 1
  end

  def self.down
    remove_column :members, :favorite_open_option
  end
end
