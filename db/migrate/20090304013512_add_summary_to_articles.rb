class AddSummaryToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :summary, :string, :limit=>1000
  end

  def self.down
    remove_column :articles, :summary
  end
end