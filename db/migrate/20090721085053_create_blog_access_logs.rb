class CreateBlogAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :blog_access_logs, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer
      t.column :blog_id, :integer, :null=>false
      t.column :created_at, :datetime
    end    
  end

  def self.down
    drop_table :blog_access_logs
  end
end
