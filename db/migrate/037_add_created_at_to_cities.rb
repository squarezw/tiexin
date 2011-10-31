class AddCreatedAtToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :created_at, :datetime
    add_column :cities, :updated_at, :datetime
    City.find(:all).each  { |city| city.update_attributes(:created_at=>Time.now)}
  end

  def self.down
    remove_column :cities, :created_at
    remove_column :cities, :updated_at
  end
end
