class AddRetryTimesToSubscriptionMessageSentLogs < ActiveRecord::Migration
  def self.up
    add_column :subscription_message_sent_logs, :sent, :boolean, :default=>false
    add_column :subscription_message_sent_logs, :retry_times, :integer, :default=>0
  end

  def self.down
    remove_column :subscription_message_sent_logs, :sent
    remove_column :subscription_message_sent_logs, :retry_times
  end
end
