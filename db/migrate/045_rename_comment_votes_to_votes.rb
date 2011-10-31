class RenameCommentVotesToVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :member_id, :integer, :null=>false
      t.column :target_type, :string, :limit => 30, :null=>false
      t.column :target_id, :integer, :null=>false
      t.column :vote, :integer
      t.column :created_at, :datetime
    end
    
    execute %q/insert into votes(member_id, target_type, target_id, vote, created_at) select member_id, 'Comment', comment_id, vote, created_at from comment_votes/
    
    drop_table :comment_votes
  end

  def self.down
    create_table :comment_votes, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :member_id, :integer, :null=>false
      t.column :comment_id, :integer, :null=>false
      t.column :vote, :integer
      t.column :created_at, :datetime
    end
    
    drop_table :votes
  end
end
