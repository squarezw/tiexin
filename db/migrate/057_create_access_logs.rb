class CreateAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :access_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer
      t.column :created_at, :datetime
      t.column :mobile, :boolean
      t.column :locale, :string, :limit=>5
      t.column :remote_ip, :string, :limit=>15
      t.column :controller, :string, :limit=>256
      t.column :action, :string, :limit=>256
      t.column :method, :string, :limit=>10
      t.column :user_agent, :string, :limit=>1024
      t.column :referer, :string, :limit=>4096
      t.column :request_uri, :string, :limit=>4096
      t.column :response_status, :string, :limit=>20
    end
  end

  def self.down
    drop_table :access_logs
  end
end
