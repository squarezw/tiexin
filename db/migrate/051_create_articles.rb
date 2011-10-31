class CreateArticles < ActiveRecord::Migration
    def self.up
      create_table :articles,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t| 
    	  t.column      :subject,   :string, :limit=>3000, :null=>false
    	  t.column      :member_id, :integer, :null=>false
    	  t.column      :folder_id,	:integer
    	  t.column      :created_at, :datetime
    	  t.column      :updated_at, :datetime
    	  t.column      :read_times, :integer, :null=>false, :default=>0
    	  t.column      :comments_count, :integer, :default=>0
    	  t.column      :hot_spot_id, :integer
    	  t.column      :brand_id, :integer
    	  t.column      :content, :text
    	end
    end

    def self.down
      drop_table :articles
    end
end
