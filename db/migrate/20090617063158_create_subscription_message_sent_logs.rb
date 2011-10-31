class CreateSubscriptionMessageSentLogs < ActiveRecord::Migration
  def self.up
    create_table :subscription_message_sent_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :subscription_message_id, :null=>false
      t.integer :member_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_message_sent_logs
  end
end
