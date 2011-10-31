class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :code, :null=>false, :limit=>8
      t.string :name, :null=>false, :limit=>300
      t.string :phone_number, :null=>false, :limit=>20
      t.string :contact_person, :limit=>60
      t.string :mail, :limit=>50
      t.string :password_hash, :null=>false, :limit=>255
      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end
