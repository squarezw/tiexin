class CreateBrands < ActiveRecord::Migration
  def self.up
    create_table :brands, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :name_zh_cn,     :string, :limit=>300
      t.column :name_en,        :string, :limit=>300
      t.column :pic,            :string       #品牌图片
      t.column :intro,          :string       #品牌介绍
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
    end
  end

  def self.down
    drop_table :brands
  end
end
