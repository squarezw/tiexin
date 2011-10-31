class AddCityForMobileToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :city_for_mobile, :integer
  end

  def self.down
    remove_column :members, :city_for_mobile
  end
end
