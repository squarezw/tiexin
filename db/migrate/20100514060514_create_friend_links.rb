class CreateFriendLinks < ActiveRecord::Migration
  def self.up
    create_table :friend_links, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true  do |t|
      t.string  :title
      t.string  :link
      t.integer :channel_id
      t.string :vendor_type
      t.integer :visit_count
      t.string :js
      t.string :pic
      t.timestamps
    end
  end

  def self.down
    drop_table :friend_links
  end
end
