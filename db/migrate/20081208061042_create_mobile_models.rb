class CreateMobileModels < ActiveRecord::Migration
  def self.up
    create_table :mobile_models, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :name,  :null=>false
      t.string :picture
      t.integer :mobile_brand_id
      t.integer :mobile_os_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mobile_models
  end
end
