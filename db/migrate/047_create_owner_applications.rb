class CreateOwnerApplications < ActiveRecord::Migration
  def self.up
    create_table :owner_applications, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :target_type, :string, :limit=>30, :null=>false
      t.column :target_id, :integer, :null=>false
      t.column :member_id, :integer, :null=>false
      t.column :status, :integer, :null=>false, :default=>0
      t.column :admin_id, :integer
      t.column :created_at, :datetime
      t.column :opinion, :string, :limit=>300
    end
  end

  def self.down
    drop_table :owner_applications
  end
end
