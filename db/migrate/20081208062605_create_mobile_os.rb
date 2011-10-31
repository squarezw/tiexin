class CreateMobileOs < ActiveRecord::Migration
  def self.up
    create_table :mobile_os do |t|
      t.string :name
      t.timestamps
    end    
  end

  def self.down
    drop_table :mobile_os
  end
end
