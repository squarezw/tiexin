class AddMobilePhoneToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :mobile_phone, :string, :limit=>20
  end

  def self.down
    remove_column :members, :mobile_phone
  end
end
