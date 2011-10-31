class AddShowInHomepageToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :show_in_homepage, :boolean, :default=>false
  end

  def self.down
    remove_column :posts, :show_in_homepage
  end
end
