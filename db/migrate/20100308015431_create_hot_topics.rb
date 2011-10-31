class CreateHotTopics < ActiveRecord::Migration
  def self.up
    create_table :hot_topics, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true  do |t|
      t.string  :title
      t.string  :link
      t.timestamps
    end
  end

  def self.down
    drop_table :hot_topics
  end
end
