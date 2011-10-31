class CreateGiftOrderItems < ActiveRecord::Migration
  def self.up
    create_table :gift_order_items, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.integer :gift_order_id, :null=>false
      t.integer :gift_id, :null=>false
      t.integer :quantity, :null=>false, :default=> 1
      t.timestamps
    end
  end

  def self.down
    drop_table :gift_order_items
  end
end
