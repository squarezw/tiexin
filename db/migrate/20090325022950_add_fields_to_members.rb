class AddFieldsToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :mail_confirm_code,  :string
    add_column :members, :mail_confirm,  :string
  end

  def self.down
    remove_column :members, :mail_confirm_code
    remove_column :members, :mail_confirm
  end
end
