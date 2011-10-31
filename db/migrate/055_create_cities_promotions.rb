class CreateCitiesPromotions < ActiveRecord::Migration
  def self.up
    #多对多关系表-中间表
    create_table :cities_promotions,:id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :city_id,:int,:null => false        #对应城市id
      t.column :promotion_id,:int,:null => false   #对应促销信息id
    end
  end

  def self.down
    drop_table :cities_promotions
  end
end
