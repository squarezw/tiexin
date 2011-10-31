class CreateReplies < ActiveRecord::Migration
  def self.up
    create_table :replies,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :member_id, :integer, :null=>false
      t.column :post_id, :integer, :null=>false
      t.column :position, :integer
      t.column :created_at, :datetime
  	  t.column :last_replied_at, :datetime
  	  t.column :vote_result, :integer, :null=>false, :default=>0
      t.column :check_status, :integer
      t.column :good_score, :integer, :null=>false, :default=>0
  	  t.column :hidden_score, :integer, :null=>false, :default=>0
  	  t.column :water_score, :integer, :null=>false, :default=>0
  	  t.column :attachment, :string
  	  t.column :content, :text
    end
  end

  def self.down
    drop_table :replies
  end
end
