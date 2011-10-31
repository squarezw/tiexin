class AddInvitationIdToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :invitation_id, :integer
  end

  def self.down
    remove_column :members, :invitation_id
  end
end
