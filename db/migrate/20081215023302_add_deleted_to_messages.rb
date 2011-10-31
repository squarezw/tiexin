class AddDeletedToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_deleted, :boolean, :default=>false
    add_column :messages, :receiver_deleted, :boolean, :default=>false
  end

  def self.down
    remove_column :messages, :sender_deleted
    remove_column :messages, :receiver_deleted
  end
end
