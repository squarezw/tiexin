class CreateCommentVotes < ActiveRecord::Migration
  def self.up
      create_table :comment_votes, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
        t.column :member_id, :integer, :null=>false
        t.column :comment_id, :integer, :null=>false
        t.column :vote, :integer
        t.column :created_at, :datetime
      end
      
      add_column :comments, :agree, :integer, :default=>0
      add_column :comments, :disagree, :integer, :default=>0
      
      execute 'update comments set agree=0, disagree=0'
  end

  def self.down
    drop_table :comment_votes
    remove_column :comments, :agree
    remove_column :comments, :disagree
  end
end
