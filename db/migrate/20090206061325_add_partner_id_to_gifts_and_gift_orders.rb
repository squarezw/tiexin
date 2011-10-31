class AddPartnerIdToGiftsAndGiftOrders < ActiveRecord::Migration
  def self.up
    add_column :gifts, :partner_id, :integer
    add_column :gift_orders, :partner_id, :integer
  end

  def self.down
    remove_column :gifts, :partner_id
    remove_column :gift_orders, :partner_id
  end
end
