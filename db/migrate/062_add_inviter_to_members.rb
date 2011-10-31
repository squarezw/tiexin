class AddInviterToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :inviter_id, :integer
  end

  def self.down
    remove_column :members, :inviter_id
  end
end
