class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t| 
      t.column  :order_sequence, :integer, :null=>false
    	t.column  :name,           :string, :limit=>150, :null=>0
    	t.column  :description,    :string, :limit=>3000   
    end
  end

  def self.down
    drop_table :forums
  end
end
