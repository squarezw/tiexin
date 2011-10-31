class AddCategoryToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_category_id, :integer
    execute "update events set event_category_id = 6 where type = 'Promotion'"
  end

  def self.down
    remove_column :events, :event_category_id
  end
end
