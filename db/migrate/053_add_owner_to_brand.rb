class AddOwnerToBrand < ActiveRecord::Migration
  def self.up
    add_column :brands, :owner_id, :integer
  end

  def self.down
    remove_column :brands, :owner_id
  end
end
