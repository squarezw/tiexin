class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :title, :string, :limit=>300, :null=>false
      t.column :member_id, :integer, :null=>false
      t.column :forum_id, :integer, :null=>false
      t.column :created_at, :datetime
  	  t.column :last_replied_at, :datetime
  	  t.column :read_times, :integer, :null=>false, :default=>0
  	  t.column :vote_result, :integer, :null=>false, :default=>0
  	  t.column :replies_count, :integer, :null=>false, :default=>0
  	  t.column :always_on_top, :boolean, :null=>false, :default=>false
  	  t.column :lock, :boolean, :null=>false, :default=>false
  	  t.column :check_status, :integer, :null=>false, :default=>0
  	  t.column :good_score, :integer, :null=>false, :default=>0
  	  t.column :hidden_score, :integer, :null=>false, :default=>0
  	  t.column :water_score, :integer, :null=>false, :default=>0
  	  t.column :attachment, :string
    end
    
    create_table :contents,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t| 
      t.column  :post_id, :integer, :null=>false
      t.column  :content, :text
    end
  end

  def self.down
    drop_table :contents
    drop_table :posts
  end
end
