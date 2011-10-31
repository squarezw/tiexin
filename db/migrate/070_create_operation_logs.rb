class CreateOperationLogs < ActiveRecord::Migration
  def self.up
    create_table :operation_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :created_at, :datetime, :null=>false
      t.column :operation, :string, :null=>false, :limit=>50
      t.column :related_object_type, :string, :limit=>50
      t.column :related_object_id, :integer
      t.column :message_key, :string, :limit=>2048
      t.column :memo, :string, :limit=>3000
      t.column :message_parameters, :text
    end
  end

  def self.down
    drop_table :operation_logs
  end
end
