class AddRecommendedToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :recommended, :boolean,  :default => false
  end

  def self.down
    remove_column :articles, :recommended
  end
end
