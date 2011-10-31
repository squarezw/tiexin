class AddFieldsForImportData < ActiveRecord::Migration
  def self.up
    add_column :traffic_lines, :fid, :integer
  end

  def self.down
    remove_column :traffic_lines, :fid
  end
end
