class AddScoreFieldToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :experience, :integer, :default => 0
    add_column :members, :credit, :integer, :default => 0 
    execute 'update members set experience = 0, credit = 0'
  end

  def self.down
    remove_column :members, :experience
    remove_column :members, :credit
  end
end
