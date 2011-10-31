class AddFieldsToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :allcity, :boolean, :default=> false  #是否是所有城市有效
  end

  def self.down
    remove_column :promotions, :allcity
  end
end
