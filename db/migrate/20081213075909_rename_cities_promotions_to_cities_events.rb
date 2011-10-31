class RenameCitiesPromotionsToCitiesEvents < ActiveRecord::Migration
  def self.up
    rename_table :cities_promotions, :cities_events
    rename_column :cities_events, :promotion_id, :event_id
  end

  def self.down
    rename_table :cities_events, :cities_promotions
    rename_column :cities_promotions, :event_id, :promotion_id
  end
end
