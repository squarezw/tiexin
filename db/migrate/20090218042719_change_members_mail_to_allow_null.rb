class ChangeMembersMailToAllowNull < ActiveRecord::Migration
  def self.up
    change_column :members, :mail, :string, :limit=>200, :null=>true
  end

  def self.down
  end
end
