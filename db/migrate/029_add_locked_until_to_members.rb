class AddLockedUntilToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :locked_until, :datetime
  end

  def self.down
    remove_column :members, :locked_until
  end
end
