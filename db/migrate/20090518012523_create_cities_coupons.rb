class CreateCitiesCoupons < ActiveRecord::Migration
  def self.up
    create_table :cities_coupons,:id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :city_id,:int,:null => false        #对应城市id
      t.column :coupon_id,:int,:null => false   #对应促销券信息id
    end
  end

  def self.down
    drop_table :cities_coupons
  end
end
