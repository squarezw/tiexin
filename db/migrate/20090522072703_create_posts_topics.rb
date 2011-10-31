class CreatePostsTopics < ActiveRecord::Migration
  def self.up
    create_table :posts_topics, :id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
       t.integer :post_id, :null=>false
       t.integer :topic_id, :null=>false
       t.timestamps
    end     
  end

  def self.down
    drop_table :posts_topics
  end
end
