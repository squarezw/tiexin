class CreateSubscriptionTopics < ActiveRecord::Migration
  def self.up
    create_table :subscription_topics do |t|
      t.string :name, :limit=>100, :null=>false
      t.integer :subject_id
      t.string :subject_type, :limit=>100
      t.boolean :sent_all
    end
  end

  def self.down
    drop_table :subscription_topics
  end
end
