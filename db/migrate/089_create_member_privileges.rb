class CreateMemberPrivileges < ActiveRecord::Migration
  def self.up
    create_table :member_privileges,  :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :privilege, :string
    end
  end

  def self.down
    drop_table :member_privileges
  end
end
