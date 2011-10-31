class CreateRoads < ActiveRecord::Migration
  def self.up
    create_table :roads, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :city_id, :integer, :null=>false
      t.column :name_zh_cn, :string, :limit=>300
      t.column :name_en, :string, :limit=>300
    end
  end

  def self.down
    drop_table :roads
  end
end
