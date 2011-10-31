class AddForumIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :post_id,  :integer
  end

  def self.down
    remove_column :articles, :post_id
  end
end
