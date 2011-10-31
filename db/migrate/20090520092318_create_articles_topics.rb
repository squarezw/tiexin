class CreateArticlesTopics < ActiveRecord::Migration
  def self.up
    create_table :articles_topics, :id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
       t.integer :article_id, :null=>false
       t.integer :topic_id, :null=>false
       t.timestamps
    end    
  end

  def self.down
    drop_table :articles_topics
  end
end
