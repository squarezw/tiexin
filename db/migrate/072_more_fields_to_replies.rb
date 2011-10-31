class MoreFieldsToReplies < ActiveRecord::Migration
  def self.up
    add_column :replies, :updated_at, :datetime
    add_column :replies, :deleted, :boolean, :null=>false, :default=>false
    
    execute 'update replies set updated_at = created_at'
  end

  def self.down
    remove_column :replies, :updated_at
    remove_column :replies, :deleted
  end
end
