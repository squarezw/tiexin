class CreateTopicExpos < ActiveRecord::Migration
  def self.up
    create_table :topic_expos do |t|
      t.integer :topic_id
      t.string :square_ids_family
      t.string :square_ids_sweet
      t.string :square_ids_grandparent
      t.string :square_ids_child
      t.string :traffic_title
      t.string :traffic_content
      t.string :exhibition_title_family
      t.string :exhibition_title_sweet
      t.string :exhibition_title_grandparent
      t.string :exhibition_title_child
      t.string :travel_line_title_family
      t.string :travel_line_title_sweet
      t.string :travel_line_title_grandparent
      t.string :travel_line_title_child
      t.string :travel_line_family, :limit => 1000
      t.string :travel_line_sweet, :limit => 1000
      t.string :travel_line_grandparent, :limit => 1000
      t.string :travel_line_child, :limit => 1000
      t.string :expo_guide
      t.string :tiexin_guide
      t.string :food_ids
      t.string :tiexin_sbx
      t.timestamps
    end
  end

  def self.down
    drop_table :topic_expos
  end
end
