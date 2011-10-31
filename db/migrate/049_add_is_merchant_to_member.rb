class AddIsMerchantToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :is_merchant, :boolean, :default=>false
    execute 'update members set is_merchant = 0'
  end

  def self.down
    remove_column :members, :is_merchant
  end
end
