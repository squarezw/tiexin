class CreateReceivedCoupons < ActiveRecord::Migration
  def self.up
    create_table :received_coupons, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :member_id, :null=>false
      t.integer :coupon_id, :null=>false
      t.string :name, :null=>false, :limit=>30
      t.string :phone_number, :null=>false, :limit=>15
      t.timestamps
    end
  end

  def self.down
    drop_table :received_coupons
  end
end
