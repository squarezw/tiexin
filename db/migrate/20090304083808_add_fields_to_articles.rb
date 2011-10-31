class AddFieldsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :rss_source_id,  :integer
    add_column :articles, :link,  :string, :limit=>500
    add_column :articles, :synch_date,  :datetime    
  end

  def self.down
    remove_column :articles, :rss_source_id
    remove_column :articles, :link
    remove_column :articles, :synch_date
  end
end
