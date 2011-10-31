class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :mail, :string, :limit=>255, :null=>false
      t.column :add_friends, :boolean, :default=>true
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :invitations
  end
end
