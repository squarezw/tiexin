class CreateDownloadLogs < ActiveRecord::Migration
  def self.up
    create_table :download_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true   do |t|
      t.column :platform, :string, :null=>false, :limit=>50
      t.column :version, :string, :null=>false, :limit=>10
      t.column :created_at, :datetime, :null=>false
    end
  end

  def self.down
    drop_table :download_logs
  end
end
