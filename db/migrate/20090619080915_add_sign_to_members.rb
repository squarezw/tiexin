class AddSignToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :sign, :string,  :limit=>3000    
  end

  def self.down
    remove_column :members, :sign
  end
end
