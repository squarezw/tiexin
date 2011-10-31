class CreateBbsBlacklists < ActiveRecord::Migration
  def self.up
    create_table :bbs_blacklists, :id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8' do |t|
       t.integer :forum_id, :null=>false
       t.integer :member_id, :null=>false
       t.timestamps
    end    
  end

  def self.down
    drop_table :bbs_blacklists
  end
end
