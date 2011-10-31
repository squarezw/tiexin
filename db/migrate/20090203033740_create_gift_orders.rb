class CreateGiftOrders < ActiveRecord::Migration
  def self.up
    create_table :gift_orders, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.integer :member_id, :null=>false
      t.integer :deliver_method, :null=>false
      t.integer :payment_method, :null=>false
      t.string :city, :limit=>300
      t.string :address, :limit=>900
      t.string :post_code, :limit=>10
      t.string :phone_number, :limit=>15
      t.string :phone_number2, :limit=>15
      t.string :name, :limit=>300
      t.integer :used_experience, :null=>false, :default=>0
      t.integer :used_credit, :null=>false, :default=>0
      t.float :cash, :null=>false, :default=>0
      t.integer :status, :null=>false, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :gift_orders
  end
end
