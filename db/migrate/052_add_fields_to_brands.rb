class AddFieldsToBrands < ActiveRecord::Migration
  def self.up
    add_column :brands, :creator_id, :integer #创建者ID
    add_column :brands, :home_page, :string, :limit=>1000 #主页
    add_column :brands, :visit_count, :integer, :default=>0  #访问量
    change_column :brands, :intro, :string, :limit => 3000
  end

  def self.down
    remove_column :brands, :creator_id
    remove_column :brands, :home_page
    remove_column :brands, :visit_count
    change_column :brands, :intro, :string
  end
end
