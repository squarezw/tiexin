class AddCityIdToTopics < ActiveRecord::Migration
  def self.up
     add_column :topics, :city_id, :integer
  end

  def self.down
     remove_column :topics, :city_id
  end
end
