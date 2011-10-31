class AddMachineCodeToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :machine_code, :string, :limit=>100
  end

  def self.down
    remove_column :members, :machine_code
  end
end
