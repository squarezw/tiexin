class AddStaffToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :is_staff, :boolean, :default=>false
  end

  def self.down
    remove_column :members, :is_staff
  end
end
