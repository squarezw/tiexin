class AddMoreGiftOrderFields < ActiveRecord::Migration
  def self.up
    add_column :gift_orders, :plan_fetch_date, :date
    add_column :gift_orders, :recommender, :string, :limit=>100
    add_column :gift_orders, :delivered_at, :datetime
  end

  def self.down
    remove_column :gift_orders, :plan_fetch_date
    remove_column :gift_orders, :recommender
    remove_column :gift_orders, :delivered_at
  end
end
