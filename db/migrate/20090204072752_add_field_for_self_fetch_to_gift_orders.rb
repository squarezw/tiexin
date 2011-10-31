class AddFieldForSelfFetchToGiftOrders < ActiveRecord::Migration
  def self.up
    add_column :gift_orders, :certificate_type, :string, :limit=>90
    add_column :gift_orders, :certificate_no, :string, :limit=>30
    add_column :gift_orders, :confirmed_at, :datetime
  end

  def self.down
    remove_column :gift_orders, :certificate_type
    remove_column :gift_orders, :certificate_no
    remove_column :gift_orders, :confirmed_at, :datetime
  end
end
