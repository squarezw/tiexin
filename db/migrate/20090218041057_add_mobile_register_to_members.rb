class AddMobileRegisterToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :mobile_register, :boolean, :default=>false
    execute 'update members set mobile_register = 0'
  end

  def self.down
    remove_column :members, :mobile_register
  end
end
