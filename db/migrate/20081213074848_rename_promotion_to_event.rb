class RenamePromotionToEvent < ActiveRecord::Migration
  def self.up
    rename_table :promotions, :events
    add_column :events, :type, :string, :limit=>20
    add_column :events, :hot_spot_id, :integer
    add_column :events, :global_id, :string, :limit=>255
    execute %q[update events set type = 'Promotion']
  end

  def self.down
    remove_column :events, :hot_spot_id
    remove_column :events, :type
    remove_column :events, :global_id
    rename_table :events, :promotions;
  end
end
