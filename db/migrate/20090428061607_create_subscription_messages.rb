class CreateSubscriptionMessages < ActiveRecord::Migration
  def self.up
    create_table :subscription_messages do |t|
      t.integer :subscription_topic_id, :null=>false
      t.integer :content_object_id, :null=>false
      t.string :content_object_type, :limit=>100, :null=>false
      t.boolean :sent
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_messages
  end
end
