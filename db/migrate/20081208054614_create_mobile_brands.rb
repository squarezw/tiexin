class CreateMobileBrands < ActiveRecord::Migration
  def self.up
    create_table :mobile_brands, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :name,  :null=>false
      t.string :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :mobile_brands
  end
end
