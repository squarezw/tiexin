class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :vendor_type, :limit=>100, :null=>false
      t.integer :vendor_id, :null=>false
      t.integer :member_id, :null=>false
      t.integer :admin_id
      t.string :type, :limit=>100, :null=>false
      t.integer :event_id
      t.date :expire_at, :null=>false
      t.boolean :all_city, :default=>false
      t.integer :status, :default=>1
      t.boolean :available, :default=>true
      t.string :summary, :limit=>3000, :null=>false
      t.text :terms 
      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
