class AddDeletedToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :deleted, :boolean, :default=>false
  end

  def self.down
    remove_column :posts, :deleted
  end
end
