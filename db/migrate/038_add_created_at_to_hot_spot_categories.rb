class AddCreatedAtToHotSpotCategories < ActiveRecord::Migration
  def self.up
    add_column :hot_spot_categories, :created_at, :datetime
    add_column :hot_spot_categories, :updated_at, :datetime
    HotSpotCategory.find(:all).each { |cat| cat.update_attributes :created_at=> Time.now}
  end

  def self.down
    remove_column :hot_spot_categories, :created_at
    remove_column :hot_spot_categories, :updated_at
  end
end
