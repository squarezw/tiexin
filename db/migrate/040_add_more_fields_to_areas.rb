class AddMoreFieldsToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :center_x, :integer
    add_column :areas, :center_y, :integer
    add_column :areas, :visit_count, :integer, :default=>0
    
    execute 'update areas set center_x = nw_x + width / 2, center_y = nw_y + height / 2, visit_count = 0'
  end

  def self.down
    remove_column :areas, :center_x
    remove_column :areas, :center_y
  end
end
