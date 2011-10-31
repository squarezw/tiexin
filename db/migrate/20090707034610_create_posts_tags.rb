class CreatePostsTags < ActiveRecord::Migration
  def self.up
     create_table :posts_tags, :id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :post_id, :null=>false
      t.integer :tag_id, :null=>false
    end    
  end

  def self.down
    drop_table :posts_tags
  end
end
