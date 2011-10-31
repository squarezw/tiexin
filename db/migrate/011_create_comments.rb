class CreateComments < ActiveRecord::Migration
  def self.up              
    create_table :comments, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|  
      t.column  :commentable_type,      :string,  :null=>false
      t.column  :commentable_id,        :integer, :null=>false
      t.column  :member_id,             :integer, :null=>false
      t.column  :created_at,            :datetime, :null=>false
      t.column  :content,               :text      
      t.column  :status,                :integer,  :default=>1
      
    end
  end

  def self.down
  end
end
