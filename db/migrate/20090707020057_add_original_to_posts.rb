class AddOriginalToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :original, :boolean
  end

  def self.down
    remove_column :posts, :original
  end
end
