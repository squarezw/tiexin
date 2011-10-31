class CreateRssSources < ActiveRecord::Migration
  def self.up
    create_table :rss_sources do |t|
      t.column :blog_id, :integer
      t.column :rss,           :string,  :limit => 500, :null => false
      t.column :title,          :string,  :limit => 2000
      t.column :description,   :text
      t.column :link,          :string,  :limit=>500
      t.column :language,      :string,  :limit=>20
      t.column :icon_url,      :string,  :limit=>500
      t.column :icon_title,    :string,  :limit=>2000
      t.column :icon_link,     :string,  :limit=>500
      t.column :score,         :integer
      t.column :folder_id,    :integer
    end
  end

  def self.down
    drop_table :rss_sources
  end
end
