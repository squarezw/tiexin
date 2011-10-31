class CreateRevises < ActiveRecord::Migration
  def self.up
    create_table :revises, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true  do |t|  
      t.column    :hot_spot_id,         :integer, :null=>false
      t.column    :member_id,           :integer, :null=>false
      t.column    :suggestion,          :string,  :limit=>2048
      t.column    :remark,              :string, :limit=>2048
      t.column    :admin_id,            :integer
      t.column    :processed_at,        :datetime
      t.column    :created_at,          :datetime
      t.column    :status,              :integer, :default=>0, :null=>false
    end
  end

  def self.down
    drop_table :revises
  end
end
