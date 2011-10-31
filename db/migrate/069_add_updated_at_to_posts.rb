class AddUpdatedAtToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :updated_at, :datetime
    
    execute 'update posts set updated_at = created_at'
  end

  def self.down
    remove_column :posts, :updated_at
  end
end
