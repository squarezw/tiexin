class CreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.string :name, :null=>false, :limit=>300
      t.integer :experience, :null=>false, :default=>0
      t.integer :credit, :null=>false, :default=>0
      t.integer :cash, :null=>false, :default=>0
      t.integer :total_quantity, :null=>false, :default=>-1   # -1 means unlimited
      t.integer :sold_quantity, :null=>false, :default=>0
      t.integer :booked_quantity, :null=>false, :default=>0
      t.integer :delivery_fee, :null=>false, :default=>0
      t.boolean :on_sale, :null=>false, :default=>true
      t.string :picture, :limit=>100
      t.text :description, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :gifts
  end
end
