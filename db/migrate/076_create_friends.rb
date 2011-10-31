class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :owner_id, :integer, :null=>false
      t.column :member_id, :integer, :null=>false
      t.column :pending, :boolean, :default=>true
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :friends
  end
end
